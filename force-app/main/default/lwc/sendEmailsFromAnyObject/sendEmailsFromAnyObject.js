import { LightningElement, track, wire } from 'lwc';
import getSObject from '@salesforce/apex/myTestingExampleMethod.getSObject';
import getPicklistFields from '@salesforce/apex/myTestingExampleMethod.getSObjectFields';
import getPicklistValues from '@salesforce/apex/myTestingExampleMethod.getPicklistFieldValues';
import getFieldData from '@salesforce/apex/myTestingExampleMethod.getFieldData';
import sendEmail from '@salesforce/apex/TestEmails.sendEmail';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class SendEmailsFromAnyObject extends LightningElement {
  objects = [];
  selectedObject;
  picklistFields = [];
  selectedField='';
  picklistValues = [];
  selectedValue='';
  oppList = []
  isData = false


  COLS ;
  columns= [
    { label: 'Name', fieldName: 'Name' },
    { label: 'Email', fieldName: 'Email__c' },
    
  ];
  connectedCallback() {
    this.COLS=this.columns

  }

  toAddress
  recepitentsIds = []
  subject = ''
  body = ''
  sendAction = false
  @track fileData;
  @track fileName;

  wantToUploadFile = false;

  @wire(getSObject)
  wiredSObject({ error, data }) {
    if (data) {
      this.objects = data.map((obj) => ({
        value: obj.apiName,
        label: obj.label,
      }));
      console.log('result Data',data)
    } else if (error) {
      console.log(error);
    }
  }

  handleChange(event) {
    this.COLS=this.columns
    this.isData = true
    this.selectedObject = event.detail.value;
    this.selectedField = ''; // reset selected field
    this.selectedValue = ''; // reset selected value
    this.picklistFields = ''
    this.picklistValues=''
    getPicklistFields({ objectName: this.selectedObject })
      .then((result) => {
        this.picklistFields = result.map((field) => {
          console.log('field.picklistValues:', field.picklistValues);
          return {
            value: field.apiName,
            label: field.label,
            options: field.picklistValues
              ? field.picklistValues.map((picklistValue) => ({
                value: picklistValue.value,
                label: picklistValue.label,
              }))
              : [],
          };
        });
      })
      .catch((error) => {
        console.log(error);
      });

    getFieldData({ objectName: this.selectedObject, fieldName: this.selectedField, Value: this.selectedValue })
      .then(result => {
        this.oppList = result.map(opp => ({ ...opp, checked: false }));
        console.log('Field Data', result)

      })
      .catch(error => {
        console.error(error)
      })
  }

  handleFieldChange(event) {
    this.selectedField = event.detail.value;
    
    console.log('options',JSON.stringify(this.picklistFields))
    let nonselectedValues=this.picklistFields.filter(item=>{
      return  !(item.value===this.selectedField)
    })
     console.log('nonselectedValues',JSON.stringify(nonselectedValues))
    const values=nonselectedValues.map(item=>{
      return item.value;
    })
 console.log('values',JSON.stringify(values))

    console.log(this.selectedField)
    const index=this.selectedField.indexOf('__c')
    console.log('index',index)
    const label=this.selectedField.slice(0,index)
      console.log('label',label)
      this.COLS=[...this.COLS,{label:label,fieldName:this.selectedField}]  
      let selectedColumns=this.COLS.filter(item=>{
    console.log(item.fieldName)
      return !(values.includes(item.fieldName))
    })
    console.log('selectedColumns',JSON.stringify(selectedColumns))
    this.COLS=selectedColumns

   

    getPicklistValues({ objectName: this.selectedObject, fieldName: this.selectedField })
      .then((result) => {
        this.picklistValues = result.map((value) => ({ label: value, value: value }));
      })
      .catch((error) => {
        console.error(error);
      });
  }


  handleValueChange(event) {
    if(this.selectedField !=''){
       
    this.selectedValue = event.detail.value;
    console.log('this.selectedValue',this.selectedValue)
    getFieldData({ objectName: this.selectedObject, fieldName: this.selectedField, value: this.selectedValue })
      .then(result => {
        this.oppList = result.map(opp => ({ ...opp, checked: false }));
        console.log('Field Data', result)
      

      })
      .catch(error => {
        console.error(error)
      })
    }else{
      alert('Select Field')
    }
  }




  //Email

  refreshHandler() {
    this.selectedField = ''
    this.selectedValue = ''
    this.picklistValues=''
    this.COLS=this.columns
    this.oppList = this.oppList.map((item) => {
      if (this.recepitentsIds.includes(item.Id)) {
        item.isChecked = false;
      }
      return item;
    });
    this.recepitentsIds = [];

    this.template.querySelector('lightning-datatable').selectedRows = [];

    getFieldData({ objectName: this.selectedObject, fieldName: this.selectedField, Value: this.selectedValue })
      .then(result => {
        this.oppList = result.map(opp => ({ ...opp, checked: false }));
        console.log('Field Data', result)


      })
      .catch(error => {
        console.error(error)
      })
  }

  handleRowSelection(event) {
    this.recepitentsIds = event.detail.selectedRows.map((row) => row.Email__c);
  }

  toggleFileUpload() {
    this.wantToUploadFile = !this.wantToUploadFile;
  }

  handleFileInputChange(event) {
    const file = event.detail.files[0];
    if (file != null) {
      this.fileName = file.name;
      this.fileData = file;
      console.log(' this. fileName', this.fileName)
      console.log(' this.filedata', this.fileData)
      this.wantToUploadFile = false;
    }

  }


  offModal() {
    this.sendAction = false
  }


  sendEmailHandler() {
    if (this.template.querySelector("lightning-datatable").getSelectedRows().length > 0) {

      this.sendAction = true
      if (this.template.querySelector("lightning-datatable").getSelectedRows().length == 1) {
        this.toAddress = this.template.querySelector("lightning-datatable").getSelectedRows().length + '' + ' recipient'
      } else {
        this.toAddress = this.template.querySelector("lightning-datatable").getSelectedRows().length + '' + ' recipients'
      }

    }
    else {
      alert('Please select members')
    }
  }

  // handleRowSelection(event) {
  //   this.recepitentsIds = event.detail.selectedRows.map((row) => row.Email__c);
  // }

  handleSubjectChange(event) {
    this.subject = event.target.value
    console.log(this.subject)
  }

  handleBodyChange(event) {
    this.body = event.target.value
    console.log(this.body)
  }

  sendEmail() {
    if (!this.fileData) {
     const emailData={
      
       subject:this.subject,
       body:this.body,
       fileName :null,
       base64Data :null
      }
      sendEmail({ toAddress :this.recepitentsIds, emailDetails:emailData })
        .then(() => {
          this.sendAction = false
          this.dispatchEvent(
            new ShowToastEvent({
              title: 'Success',
              message: 'Email sent successfully',
              variant: 'success'
            })
          );
          console.log('success')
        })
        .catch(error => {
          this.dispatchEvent(
            new ShowToastEvent({
              title: 'Error',
              message: error.body.message,
              variant: 'error'
            })
          );
          console.error(error)
        })
      return;
    }

    const reader = new FileReader();
    reader.readAsDataURL(this.fileData);
    reader.onloadend = () => {
      const base64Data = reader.result.split(',')[1];
     const emailData={
      
       subject:this.subject,
       body:this.body,
       fileName : this.fileName,
       base64Data :base64Data
      }
      sendEmail({  toAddress :this.recepitentsIds,emailDetails:emailData })
        .then(() => {
          this.sendAction = false
          this.dispatchEvent(
            new ShowToastEvent({
              title: 'Success',
              message: 'Email sent successfully',
              variant: 'success'
            })
          );
          console.log('success')
        })
        .catch(error => {
          this.dispatchEvent(
            new ShowToastEvent({
              title: 'Error',
              message: error.body.message,
              variant: 'error'
            })
          );
          console.error(error)
        })
    }

  }



  handleRemove() {
    this.fileData = ''
  }

}