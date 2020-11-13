import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { subscribe, unsubscribe, onError, setDebugFlag, isEmpEnabled } from 'lightning/empApi';

export default class ChangePlatformEventComponent extends LightningElement {

    channelName = '/event/Account_Change__e';
    @api recordId;

    
    connectedCallback() {       

        this.registerEventListener();      
    }

    registerEventListener() {

        const thisRef = this;

        const messageCallback = function(response) {
            console.log('New message received: ', JSON.stringify(response));
            var obj = JSON.parse(JSON.stringify(response));
            thisRef.showSuccessToast(obj);
        };

        // Invoke subscribe method of empApi. Pass reference to messageCallback
        subscribe(this.channelName, -1, messageCallback);
    }

    showSuccessToast(object) {

        if(object.data.payload.Account_Id__c == this.recordId) {

            const evt = new ShowToastEvent({
                title: 'Account was updated!',
                message: object.data.payload.Message__c,
                variant: 'success',
            });
    
            this.dispatchEvent(evt);
        }
        
    }
}