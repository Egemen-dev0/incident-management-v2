import cds from '@sap/cds'

export class ProcessorService extends cds.ApplicationService {
  init() {
    this.before('UPDATE', 'Incidents', req => this.onUpdate(req))
    this.before(['CREATE', 'UPDATE'], 'Incidents', req => this.changeUrgencyDueToSubject(req.data))
    return super.init()
  }

  changeUrgencyDueToSubject(data) {
    if (data.title?.match(/urgent/i)) data.urgency_code = 'H'
  }

  async onUpdate(req) {
    const closed = await SELECT.one(1).from(req.subject).where`status.code = 'C'`
    if (closed) req.reject`Can't modify a closed incident!`
  }
}