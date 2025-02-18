pageextension 81801 "SPT Payment Terms" extends "Payment Terms" //4
{
    actions
    {
        addfirst(Category_New)
        {
            actionref(SPTGenerateCopilotPromoted; SPTGenerateCopilotAction)
            {
            }
        }

        addlast(Prompting)
        {
            action(SPTGenerateCopilotAction)
            {
                Caption = 'Draft with Copilot';
                Ellipsis = true;
                ApplicationArea = All;
                ToolTip = 'Lets Copilot generate a draft payment terms based on your description.';
                Image = Sparkle;

                trigger OnAction()
                begin
                    Page.RunModal(Page::"SPT SuggestPT - Proposal");
                end;
            }
        }
    }
}