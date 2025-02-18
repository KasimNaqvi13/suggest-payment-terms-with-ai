page 81803 "SPT PT AI Setup"
{
    ApplicationArea = All;
    Caption = 'Suggest Payment Terms Setup';
    PageType = Card;
    SourceTable = "SPT PT AI Setup";
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field("Model Name"; Rec."Model Name")
                {
                    ToolTip = 'Specifies the value of the Model Name field.', Comment = '%';
                }
                field("Endpoint URL"; Rec."Endpoint URL")
                {
                    ToolTip = 'Specifies the value of the Endpoint URL field.', Comment = '%';
                }
                field(APIKey; APIKey)
                {
                    ApplicationArea = All;
                    Caption = 'API Key';
                    ToolTip = 'API Key';
                    ExtendedDatatype = Masked;
                    trigger OnValidate()
                    begin
                        Rec.SetSecret(APIKey);
                    end;
                }
            }
        }
    }
    trigger OnOpenPage()
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;
    end;

    trigger OnAfterGetCurrRecord()
    begin
        if not Rec.GetSecret().IsEmpty() then
            APIKey := '****'
        else
            APIKey := '';
    end;

    var
        [NonDebuggable]
        APIKey: Text;
}
