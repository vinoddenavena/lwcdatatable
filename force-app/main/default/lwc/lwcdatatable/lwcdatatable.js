import { LightningElement , wire , track} from 'lwc';

import { updateRecord, deleteRecord } from 'lightning/uiRecordApi';
import First_Name from '@salesforce/schema/Contact.FirstName';
import Last_Name from '@salesforce/schema/Contact.LastName';
import ID_Field from '@salesforce/schema/Contact.Id';
import { NavigationMixin } from 'lightning/navigation';
import {refreshApex} from '@salesforce/apex';
import getContacts from '@salesforce/apex/myApexClass.methodContacts';

const CL = [
    { label: 'First Name', fieldName: 'FirstName', editable: true },
    { label: 'Last Name', fieldName: 'LastName', editable: true },
    { label: 'Email', fieldName: 'Email', editable: true },
    { label: 'Phone', fieldName: 'Phone', editable: true },
    {
        type: 'button',
        initialWidth: 100,
        typeAttributes: {
            label: 'Delete',
            name: 'Delete',
            title: 'Delete',
            variant: 'base',
        }
    },
    {
        type: 'button',
        initialWidth: 100,
        typeAttributes: {
            label: 'Pass Id',
            name: 'Pass Id',
            title: 'Pass Id',
            variant: 'base',
        }
    }
];



export default class Lwcdatatable extends LightningElement {
    columnsList = CL;
    draftValues = [];
    selectedRecordIds = [];
    @wire(getContacts)
    allContacts;

    handleRowAction(event) {
        const fields = {};
        fields[ID_Field.fieldApiName] = event.detail.draftValues[0].Id;
        fields[First_Name.fieldApiName] = event.detail.draftValues[0].FirstName;
        fields[Last_Name.fieldApiName] = event.detail.draftValues[0].LastName;

     console.log(`the id was ${event.detail.draftValues[0].Id} the firstName was ${event.detail.draftValues[0].FirstName} the last name is ${event.detail.draftValues[0].LastName}`)
        const recordInput = {
            fields: fields
        };

        updateRecord(recordInput)
            .then(() => {
                alert('Record updated successfully');
            })
            .catch(error => {
                alert(error.body.message);
            });
    }

    handleRowSelection(event) {
        this.selectedRecordIds = event.detail.selectedRows.map(row => row.Id);
        console.log('Selected Record IDs:', this.selectedRecordIds);
    }

    handleDeleteRecord(event) {
        const rowId = event.detail.row.Id;
        const action = event.detail.action;

        if (action.name === 'Delete') {
            this.deleteRecord(rowId);
            console.log('Record to be deleted:', rowId);
        } else if (action.name === 'Pass Id') {
             this[NavigationMixin.Navigate]({
      type: 'standard__navItemPage',
      attributes: {
        apiName: 'Home'
      },
      state: {
        c__rowId: this.rowId
      }
    });
        }
    }

    deleteRecord(recordId) {
        deleteRecord(recordId)
            .then(response => {
                alert('Record deleted successfully');
            })
            .catch(error => {
                alert('Unable to delete the record: ' + error.body.message);
            });
    }

    handleClickDeleteAllRecords(event) {
        const action = event.target.title;
        if (action === 'Delete all records') {
            this.deleteRecord(this.selectedRecordIds);
            alert('Deleting all records');
        }else if(action === 'Pass Id'){
              this[NavigationMixin.Navigate]({
      type: 'standard__navItemPage',
      attributes: {
        apiName: 'Account'
      },
      state: {
        c__rowId: this.rowId
      }
    });
        }
    }
 


 


    


// how to write wire when we need to write refresh apex to a wire
mydata;
 

handlerefresh(){
refreshApex(mydata);
}

handleimperative(){
    getContacts()
    .then(result=>{
        this.mydata = result;
    })
    .catch(error=>{
        console.log(error);
    })
}

}