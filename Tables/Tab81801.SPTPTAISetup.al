table 81801 "SPT PT AI Setup"
{
    Caption = 'Payment Terms AI Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
        }
        field(2; "Endpoint URL"; Text[200])
        {
            Caption = 'Endpoint URL';
        }
        field(3; "Model Name"; Text[200])
        {
            Caption = 'Model Name';
        }
    }
    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }
    procedure SetSecret(Secret: SecretText)
    begin
        if IsolatedStorage.Contains(StorageKeyLbl, DataScope::Company) then
            IsolatedStorage.Delete(StorageKeyLbl, DataScope::Company);

        IsolatedStorage.set(StorageKeyLbl, Secret, DataScope::Company);
    end;

    procedure GetSecret(): SecretText
    var
        Secret: SecretText;
    begin
        if IsolatedStorage.Contains(StorageKeyLbl, DataScope::Company) then begin
            IsolatedStorage.Get(StorageKeyLbl, DataScope::Company, Secret);
            exit(Secret);
        end;
    end;

    var
        StorageKeyLbl: Label '06223f93-9f38-4c69-a46c-e27cb87743b2', Locked = true;
}
