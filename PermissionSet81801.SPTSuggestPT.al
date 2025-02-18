permissionset 81801 "SPT Suggest PT"
{
    Caption = 'Sugget Payment Terms with AI';
    Assignable = true;
    Permissions = codeunit "SPT Create Payment Terms" = X,
        codeunit "SPT Generate Proposal" = X,
        codeunit "SPT Install" = X,
        page "SPT Payment Terms ProposalSub." = X,
        page "SPT SuggestPT - Proposal" = X,
        tabledata "SPT PT AI Setup" = RIMD,
        table "SPT PT AI Setup" = X;
}