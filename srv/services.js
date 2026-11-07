import cds from '@sap/cds'

export class ProcessorService extends cds.ApplicationService {
  async init() {
    this.before('UPDATE', 'Incidents', req => this.onUpdate(req))
    this.before(['CREATE', 'UPDATE'], 'Incidents', req => this.changeUrgencyDueToSubject(req.data))
    this.on('READ', 'Customers', req => this.onCustomerRead(req))
    this.on(['CREATE', 'UPDATE'], 'Incidents', (req, next) => this.onCustomerCache(req, next))
    this.S4bupa = await cds.connect.to('API_BUSINESS_PARTNER')
    this.remoteService = await cds.connect.to('RemoteService')
    return super.init()
  }

  changeUrgencyDueToSubject(data) {
    if (data.title?.match(/urgent/i)) data.urgency_code = 'H'
  }

  async onUpdate(req) {
    const closed = await SELECT.one(1).from(req.subject).where`status.code = 'C'`
    if (closed) req.reject`Can't modify a closed incident!`
  }

  async onCustomerCache(req, next) {
    const { Customers } = this.entities
    const newCustomerId = req.data.customer_ID
    const result = await next()
    const { BusinessPartner } = this.remoteService.entities
    if (newCustomerId && newCustomerId !== '') {
      console.log('>> CREATE or UPDATE customer!')
      // Expands are required as the runtime does not support path expressions for remote services
      const customer = await this.S4bupa.run(SELECT.one(BusinessPartner, bp => {
        bp('*')
        bp.addresses(address => {
          address.email(emails => { emails('email') })
          address.phoneNumber(phoneNumber => { phoneNumber('phone') })
        })
      }).where({ ID: newCustomerId }))

      if (customer) {
        customer.email = customer.addresses[0]?.email[0]?.email
        delete customer.name
        await UPSERT.into(Customers).entries(customer)
      }
    }
    return result
  }

  async onCustomerRead(req) {
    console.log('>> delegating to S4 service...', req.query)
    const top = parseInt(req._queryOptions?.$top) || 100
    const skip = parseInt(req._queryOptions?.$skip) || 0
    const { BusinessPartner } = this.remoteService.entities

    // Expands are required as the runtime does not support path expressions for remote services
    let result = await this.S4bupa.run(SELECT.from(BusinessPartner, bp => {
      bp('*')
      bp.addresses(address => {
        address.email(emails => { emails('email') })
      })
    }).limit(top, skip))

    result = result.map(bp => ({
      ID: bp.ID,
      name: bp.name,
      email: bp.addresses[0]?.email[0]?.email
    }))

    // Explicitly set $count so the values show up in the value help in the UI
    result.$count = 1000
    return result
  }
}