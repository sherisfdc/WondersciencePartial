import { LightningElement, track , wire } from 'lwc';
import createEvent from '@salesforce/apex/EventCreationController.createEvent';
import getEventList from '@salesforce/apex/EventCreationController.getEventList';
import deleteEvent from '@salesforce/apex/EventCreationController.deleteEvent';
import EVENT_SUBJECT from '@salesforce/schema/Event.Subject';
import EVENT_START from '@salesforce/schema/Event.StartDateTime';
import EVENT_END from '@salesforce/schema/Event.EndDateTime';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import {refreshApex} from '@salesforce/apex';

const actions = [
{label:'Delete',name : 'delete',iconName:'action:delete'},
];

const columns = [
{label:'Subject' , fieldName: 'Subject' , type : 'text'},
{label:'Start' , fieldName: 'StartDateTime' , type : 'date'
,typeAttributes:{day:'numeric',month:'short',year:'numeric',
hour:'2-digit',minute:'2-digit',second:'2-digit',hour12:true , timeZone:'UTC'}},
{label:'End' , fieldName: 'EndDateTime' , type : 'date'
,typeAttributes:{day:'numeric',month:'short',year:'numeric',
hour:'2-digit',minute:'2-digit',second:'2-digit',hour12:true ,timeZone:'UTC'}},
{
type : 'action',
typeAttributes : {rowActions : actions}
},
]

export default class EventCreation_Apex extends LightningElement {

@track error; 
@track data;

columns = columns;

@track eventrecord = {
Subject: EVENT_SUBJECT,
StartDateTime: EVENT_START,
EndDateTime: EVENT_END

}

value = [];
_Allowrecurring = false;
_wiredResult;

get options() {
return [
    { label: 'Monday', value: 'Monday' },
    { label: 'Tuesday', value: 'Tuesday' },
    { label: 'Wednesday', value: 'Wednesday' },
    { label: 'Thursday', value: 'Thursday' },
    { label: 'Friday', value: 'Friday' },
    { label: 'Saturday', value: 'Saturday' },
    { label: 'Sunday', value: 'Sunday' }
];
}

get selectedValues() {
return this.value.join(',');
}

handleChange(e) {
this.value = e.detail.value;
}
handleRecurrChange(e)
{
if(e.detail.checked == true)
{
this._Allowrecurring = true;
    this.template.querySelector(".chk_grp").disabled = false;
    this.template.querySelector(".chk_grp_dv").hidden = '';
}
else
{
this._Allowrecurring = false;
this.template.querySelector(".chk_grp").disabled = true;
this.template.querySelector(".chk_grp_dv").hidden = 'hidden';
}
}


handleStartChange(event)
{
this.eventrecord.StartDateTime = event.target.value;
this.eventrecord.Subject = 'Availability';
}
handleEndChange(event)
{
this.eventrecord.EndDateTime = event.target.value;
}

handleSaveEvent()
{
this.eventrecord.SelectedValuess = this.value.join(',');
createEvent({eventrecObj:this.eventrecord,Allowrecurring : this._Allowrecurring , SelectedValuess : this.value.join(',')})
.then(result=>{      
console.log('message',result);
if(result == 'EVENT CREATED SUCCESSFULLY')
{
    this.eventrecord = {};
const toastEvent = new ShowToastEvent({
    title: 'Success !',
    message:result,
    variant:'success'
});
this.dispatchEvent(toastEvent);
return refreshApex(this._wiredResult);
}
else
{
const toastEvent = new ShowToastEvent({
    title: 'INFO !',
    message:result,
    variant:'error'
    });
    this.dispatchEvent(toastEvent);
}
})
.catch(error=>{
this.error = error.message;

});
}

get todaysDate() {
var today = new Date();
//var onlyDate = today.toLocaleString().split(' ')[0];
console.log('today' , today);
return today;
}
@wire (getEventList) 
eventRecords(wireResult)
{
const { data, error } = wireResult;
console.log('startdate',data);
this._wiredResult = wireResult;
if(data)
{
this.data = data;
}
else if(error)
{
this.data = undefined;
}
}

handleRowAction(event)
{
debugger
const actionName = event.detail.action.name;
const rowId = event.detail.row.Id;
console.log('rowId',rowId);
console.log('action',actionName);
this.deleteEventRecord(rowId);

}

deleteEventRecord(rowId)
{
debugger
//const selectedRow = currentRow;
//console.log(currentRow)

deleteEvent({lwcrecordId : rowId})
.then(result=>{       
if(result == true)
{
const toastEvent = new ShowToastEvent({
    title: 'Delete !',
    message:'Event record is deleted Successfully',
    variant:'success'
});       
this.dispatchEvent(toastEvent);
//window.location.reload();
console.log('data',this._wiredResult);
return refreshApex(this._wiredResult);
}       
})
.catch(error=>{
this.error = error.message;

});
}

}