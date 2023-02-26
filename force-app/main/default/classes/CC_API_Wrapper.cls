public class CC_API_Wrapper {
    public String id;   //b2b782d4-8c16-452e-90fe-0a967daf25d8
    public String firstName;    //First
    public String lastName; //Last
    public String email;    //test@wondermed.com
    public String phoneNumber;  //+1 (222) 221-4444
    public string stateIdNumber;
    public String biologicalSex;    //female
    public String preferredPronouns;    //they-them-theirs
    public String relationshipStatus;   //married
    public String occupation;   //occupation
    public String employer; //Employer
    public String birthDate;    //2000-01-01T00:00:00.000Z
    public boolean confirmedEmail;
    public String authorizeNetCustomerId;   //cus_KUrgwRNIT71jls
    public String lastSignedInAt;   //2021-11-30T06:06:53.191Z
    public String createdAt;    //2021-09-02T13:18:43.744Z
    public String updatedAt;    //2021-11-30T06:06:53.191Z
    public String ssn;
    public string referralCode;
    public integer heightFeet;
    public integer heightInches;
    public integer weight;
    public cls_customerJourney customerJourney; 
    public cls_discountCode discountCode;
    public cls_allyContact allyContact;
    public cls_emergencyContact emergencyContact;
    public cls_onboardingWizard onboardingWizard;
    public cls_billingAddress billingAddress;
    public cls_shippingAddress shippingAddress;
    public cls_formSubmissions[] formSubmissions;
    public class cls_allyContact {
        public String name; //ally
        public String email;    //ally@wondermed.com
        public string consentedAt;
        public String createdAt;    //2021-11-11T16:54:01.351Z
        public String updatedAt;    //2021-11-30T06:06:53.190Z
    }
    public class cls_emergencyContact {
        public String name; //contact
        public String phoneNumber;  //+1 (111) 111-1111
        public String relationship; //rel
        public String createdAt;    //2021-11-11T16:54:01.344Z
        public String updatedAt;    //2021-11-30T06:06:53.187Z
    }
    public class cls_onboardingWizard {
        public string completedAt;
        public String lastCompletedStep;    //personal-info
        public String createdAt;    //2021-09-02T13:18:43.744Z
        public String updatedAt;    //2021-12-03T15:36:06.128Z
        public string[] enumValues;
    }
    public class cls_billingAddress {
        public String city; //LA
        //public String country;    //US
        public String addressLine1; //tet.
        public String addressLine2; //test1
        public String postalCode;   //77777
        public String state;    //CA
    }
    public class cls_shippingAddress {
        public String city;     //LA
        //public String country;    //US
        public String addressLine1; //test 1
        public String addressLine2;     //test 2
        public String postalCode;   //77777
        public String state;    //CA
    }
    public class cls_formSubmissions 
    {
        public String id;   //bcba5b1f-559f-49fd-92bd-2abb8cc3fb99
        public cls_forms form;
        public cls_questions[] questions;
    }
    
    public class cls_forms {
        public String id;   //bcba5b1f-559f-49fd-92bd-2abb8cc3fb99
        public String slug; //new-patient-intake
    }
    public class cls_questions {
        public String id;   //ce283daa-6484-4594-b13a-5251d1ab7ef2
        public String text; //Have any of these applied to you? (Select all that apply)
        public String type; //multi
        public cls_data data;
        public cls_answers[] answers;
    }
    public class cls_data {
        public string[] options;
        public String noneOption;   //None of the above
    }
    public class cls_answers {
        public String answer;   //Elevated Intraocular Pressure (ex: glaucoma)
        public String createdAt;    //2021-12-08T08:43:52.022Z
        public String updatedAt;    //2021-12-08T08:43:52.022Z
    }
    public class cls_customerJourney{
        public string stage;
        public string salesforceOpportunityId;
        public string opportunityType;
    }
    public class cls_discountCode{
        public string code;
    }
    public static CC_API_Wrapper parse(String json){
        return (CC_API_Wrapper) System.JSON.deserialize(json, CC_API_Wrapper.class);
    }
}