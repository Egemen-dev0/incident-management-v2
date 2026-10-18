using ProcessorService as service from '../../srv/services';
using from '../../db/schema';

annotate service.Customers with @title : '{i18n>Customer}';
annotate service.Incidents with @title : '{i18n>Incident}';

// ---------- List page ----------
annotate service.Incidents with @(
  UI.SelectionFields : [ status_code, urgency_code ],
  UI.LineItem : [
    { $Type : 'UI.DataField', Value : title,         Label : '{i18n>Title}' },
    { $Type : 'UI.DataField', Value : customer.name, Label : '{i18n>Customer}' },
    { $Type : 'UI.DataField', Value : status.descr,  Label : '{i18n>Status}', Criticality : status.criticality },
    { $Type : 'UI.DataField', Value : urgency.descr, Label : '{i18n>Urgency}' },
  ]
);

// ---------- Object page ----------
annotate service.Incidents with @(
  UI.HeaderInfo : {
    TypeName       : '',
    TypeNamePlural : '',
    Title          : { $Type : 'UI.DataField', Value : title },
    Description    : { $Type : 'UI.DataField', Value : customer.name },
    TypeImageUrl   : 'sap-icon://alert',
  },
  UI.FieldGroup #GeneratedGroup : {
    $Type : 'UI.FieldGroupType',
    Data : [
      { $Type : 'UI.DataField', Value : title,       Label : '{i18n>Title}' },
      { $Type : 'UI.DataField', Value : customer_ID, Label : '{i18n>Customer}' },
    ],
  },
  UI.FieldGroup #i18nDetails : {
    $Type : 'UI.FieldGroupType',
    Data : [
      { $Type : 'UI.DataField', Value : status_code, Criticality : status.criticality },
      { $Type : 'UI.DataField', Value : urgency_code },
    ],
  },
  UI.Facets : [
    {
      $Type : 'UI.CollectionFacet', ID : 'i18nOverview', Label : '{i18n>Overview}',
      Facets : [
        { $Type : 'UI.ReferenceFacet', ID : 'GeneratedFacet1', Label : '{i18n>GeneralInformation}', Target : '@UI.FieldGroup#GeneratedGroup' },
        { $Type : 'UI.ReferenceFacet', ID : 'i18nDetails',     Label : '{i18n>Details}',            Target : '@UI.FieldGroup#i18nDetails' },
      ],
    },
    { $Type : 'UI.ReferenceFacet', ID : 'i18nConversation', Label : '{i18n>Conversation}', Target : 'conversation/@UI.LineItem#i18nConversation' },
  ]
);

// ---------- Field labels, texts, value helps ----------
annotate service.Incidents with {
  status   @Common.Label : '{i18n>Status}'   @Common.Text : status.descr   @Common.ValueListWithFixedValues : true;
  urgency  @Common.Label : '{i18n>Urgency}'  @Common.Text : urgency.descr  @Common.ValueListWithFixedValues : true;
  customer @Common.Text : { $value : customer.name, ![@UI.TextArrangement] : #TextOnly }
           @Common.ValueListWithFixedValues : false
           @Common.ValueList : {
             $Type : 'Common.ValueListType',
             CollectionPath : 'Customers',
             Parameters : [
               { $Type : 'Common.ValueListParameterInOut',       LocalDataProperty : customer_ID, ValueListProperty : 'ID' },
               { $Type : 'Common.ValueListParameterDisplayOnly', ValueListProperty : 'name' },
               { $Type : 'Common.ValueListParameterDisplayOnly', ValueListProperty : 'email' },
             ],
           };
};
annotate service.Status  with { code @Common.Text : descr };
annotate service.Urgency with { code @Common.Text : descr };

// ---------- Conversation table ----------
annotate service.Incidents.conversation with @(
  title : '{i18n>Conversation}',
  UI.LineItem #i18nConversation : [
    { $Type : 'UI.DataField', Value : author,    Label : '{i18n>Author}' },
    { $Type : 'UI.DataField', Value : message,   Label : '{i18n>Message}' },
    { $Type : 'UI.DataField', Value : timestamp, Label : '{i18n>ConversationDate}' },
  ]
);