page 81802 "SPT SuggestPT - Proposal"
{
    PageType = PromptDialog;
    Extensible = false;
    Caption = 'Draft new payment terms with Copilot';
    DataCaptionExpression = InputPaymentTermsDescription;
    IsPreview = true;

    layout
    {
        #region input section
        area(Prompt)
        {
            field(PaymentTermsDescriptionField; InputPaymentTermsDescription)
            {
                ApplicationArea = All;
                ShowCaption = false;
                MultiLine = true;
                InstructionalText = 'Describe the payment terms you want to create with Copilot vld-bc.com';
            }
        }
        #endregion

        #region output section
        area(Content)
        {
            part(ProposalDetails; "SPT Payment Terms ProposalSub.")
            {
                Caption = 'Payment Terms';
                ShowFilter = false;
                ApplicationArea = All;
            }
        }
        #endregion
    }
    actions
    {
        #region prompt guide
        area(PromptGuide)
        {
            action(NetDate)
            {
                ApplicationArea = All;
                Caption = 'Net date';
                ToolTip = 'Net date';

                trigger OnAction()
                begin
                    InputPaymentTermsDescription := 'Create payment terms where the due date is [DueDateNumberOfDays] days from the invoice date.';
                end;
            }
            action(NetDateEOM)
            {
                ApplicationArea = All;
                Caption = 'Net date after End of Month';
                ToolTip = 'Net date after End of Month';

                trigger OnAction()
                begin
                    InputPaymentTermsDescription := 'Create payment terms where the due date is [DueDateNumberOfDays] days after end of current month from the invoice date.';
                end;
            }
            action(NetDateWithDiscount)
            {
                ApplicationArea = All;
                Caption = 'Net date with discount';
                ToolTip = 'Net date with discount';

                trigger OnAction()
                begin
                    InputPaymentTermsDescription := 'Create payment terms where the due date is [DueDateNumberOfDays] days from the invoice date and the discount is available if paid [DiscountDateNumberOfDays] days after the invoice date with a discount rate of [PaymentDiscountPercent]%.';
                end;
            }
            action(NetDateAndCurrentFixedDayOfMonth)
            {
                ApplicationArea = All;
                Caption = 'Net Date and current fixed Day of Month';
                ToolTip = 'Net Date and current fixed Day of Month';

                trigger OnAction()
                var
                    TxtBuilder: TextBuilder;
                begin
                    TxtBuilder.AppendLine('Create payment terms where the due date is [DueDateNumberOfDays] days from the invoice date.');
                    TxtBuilder.AppendLine('Generate Payment Terms for every [DiscountDateDayOfMonth]th of the month with a payment discount of [PaymentDiscountPercent]% and due date on the [DueDateDayOfMonth]th of the month.');
                    InputPaymentTermsDescription := TxtBuilder.ToText();
                end;
            }
            group(FixedDayOfMonth)
            {
                Caption = 'Fixed Day of Month';
                ToolTip = 'Fixed Day of Month';
                action(CurrentFixedDayOfMonth)
                {
                    ApplicationArea = All;
                    Caption = 'Fixed day of current Month with discount';
                    ToolTip = 'Fixed day of current Month with discount';

                    trigger OnAction()
                    begin
                        InputPaymentTermsDescription := 'Generate Payment Terms for every [DiscountDateDayOfMonth]th of the month with a payment discount of [PaymentDiscountPercent]% and due date on the [DueDateDayOfMonth]th of the month.';
                    end;
                }
                action(NextFixedDayOfMonth)
                {
                    ApplicationArea = All;
                    Caption = 'Fixed day of next Month with discount';
                    ToolTip = 'Fixed day of next Month with discount';

                    trigger OnAction()
                    begin
                        InputPaymentTermsDescription := 'Generate Payment Terms for every [DiscountDateDayOfMonth]th of the next month with a payment discount of [PaymentDiscountPercent]% and due date on the [DueDateDayOfMonth]th of the next month.';
                    end;
                }
            }
        }
        #endregion

        #region system actions
        area(SystemActions)
        {
            systemaction(Generate)
            {
                Caption = 'Generate';
                ToolTip = 'Generate a payment terms with Dynamics 365 Copilot.';

                trigger OnAction()
                begin
                    RunGeneration();
                end;
            }
            systemaction(OK)
            {
                Caption = 'Keep it';
                ToolTip = 'Save the Payment Terms proposed by Dynamics 365 Copilot.';
            }
            systemaction(Cancel)
            {
                Caption = 'Discard it';
                ToolTip = 'Discard the Payment Terms proposed by Dynamics 365 Copilot.';
            }
            systemaction(Regenerate)
            {
                Caption = 'Regenerate';
                ToolTip = 'Regenerate the Payment Terms proposed by Dynamics 365 Copilot.';

                trigger OnAction()
                begin
                    RunGeneration();
                end;
            }
            #endregion
        }
    }
    #region triggers and code
    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if CloseAction = CloseAction::OK then
            Save();
    end;

    local procedure RunGeneration()
    var
        SuggestPaymentTermsGenerateProposal: Codeunit "SPT Generate Proposal";
        ProgressDialog: Dialog;
        Attempts: Integer;
    begin
        if InputPaymentTermsDescription = '' then
            Error(PaymentTermsDescriptionEmptyErr);

        if StrLen(InputPaymentTermsDescription) < 20 then
            Message(DescriptionTooShortMsg);

        ProgressDialog.Open(GeneratingTextDialogTxt);
        SuggestPaymentTermsGenerateProposal.SetUserPrompt(InputPaymentTermsDescription);

        TempPaymentTerms.Reset();
        TempPaymentTerms.DeleteAll();

        for Attempts := 0 to 3 do
            if SuggestPaymentTermsGenerateProposal.Run() then
                if SuggestPaymentTermsGenerateProposal.GetResult(TempPaymentTerms) then begin
                    CurrPage.ProposalDetails.Page.Load(TempPaymentTerms);
                    exit;
                end;

        if GetLastErrorText() = '' then
            Error(SomethingWentWrongErr)
        else
            Error(SomethingWentWrongWithLatestErr, GetLastErrorText());
    end;

    procedure Save()
    var
        PaymentTerms: Record "Payment Terms";
    begin
        if TempPaymentTerms.FindSet() then
            repeat
                PaymentTerms.Init();
                PaymentTerms.TransferFields(TempPaymentTerms);
                PaymentTerms.Insert(true);
            until TempPaymentTerms.Next() = 0;
    end;
    #endregion

    #region global variables
    var
        TempPaymentTerms: Record "Payment Terms" temporary;
        InputPaymentTermsDescription: Text;
        GeneratingTextDialogTxt: Label 'Generating with Copilot...';
        SomethingWentWrongErr: Label 'Something went wrong. Please try again.';
        SomethingWentWrongWithLatestErr: Label 'Something went wrong. Please try again. The latest error is: %1', Comment = '%1 = Latest Error';
        PaymentTermsDescriptionEmptyErr: Label 'Please describe a payment terms that Copilot can draft for you.';
        DescriptionTooShortMsg: Label 'The description of the payment terms is too short, and this might impact the result quality.';
    #endregion
}