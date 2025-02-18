page 81801 "SPT Payment Terms ProposalSub."
{
    PageType = ListPart;
    Extensible = false;
    ApplicationArea = All;
    UsageCategory = Administration;
    Caption = 'Dynamics 365 Copilot Payment Terms';
    SourceTable = "Payment Terms";
    SourceTableTemporary = true;

    layout
    {
        area(Content)
        {
            repeater(PaymentTerms)
            {
                Caption = ' ';
                ShowCaption = false;

                field("Code"; Rec."Code")
                {
                    ToolTip = 'Specifies a code for the SAT payment term.';
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies a description of the SAT payment term.';
                }
                field("Due Date Calculation"; Rec."Due Date Calculation")
                {
                    ToolTip = 'Specifies a formula that determines how to calculate the due date, for example, when you create an invoice.';
                }
                field("Discount Date Calculation"; Rec."Discount Date Calculation")
                {
                    ToolTip = 'Specifies the date formula if the payment terms include a possible payment discount.';
                }
                field("Discount %"; Rec."Discount %")
                {
                    ToolTip = 'Specifies the percentage of the invoice amount (amount including VAT is the default setting) that will constitute a possible payment discount.';
                }
            }
        }
    }

    internal procedure Load(var TempPaymentTerms: Record "Payment Terms" temporary)
    begin
        Rec.Reset();
        Rec.DeleteAll();
        Rec.Copy(TempPaymentTerms, true);

        CurrPage.Update(false);
    end;
}