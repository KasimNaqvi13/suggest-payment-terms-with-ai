codeunit 81802 "SPT Create Payment Terms" implements "AOAI Function"
{
    var
        FunctionNameLbl: Label 'create_paymentterms', Locked = true;

    procedure GetPrompt(): JsonObject
    var
        ToolDefinition: JsonObject;
        FunctionDefinition: JsonObject;
        ParametersDefinition: JsonObject;
    begin
        ParametersDefinition.ReadFrom(
            '{"type": "object",' +
            '"properties": {' +
                '"code": { "type": "string", "description": "A short code for payment terms (max 10 characters)."},' +
                '"desc": { "type": "string", "description": "A short description for this payment terms (max 100 characters)."},' +
                '"dueDateCalculation": { "type": "string", "description": "Specifies a date formula for calculating the due date relative to the invoice date. If a fixed day-of-month is mentioned (e.g., 20th), convert it to the corresponding Business Central formula (e.g., -CM+19D). Valid examples: 3D, -CM+7D, 1W, CW+1D."},' +
                '"discountDateCalculation": { "type": "string", "description": "Specifies the date formula for the discount date relative to the invoice date. If a fixed day-of-month is mentioned (e.g., 12th), convert it to the corresponding Business Central formula (e.g., -CM+11D). Otherwise, use a relative day count. Valid examples: 3D, -CM+7D, 1W, CW+1D. Empty string if not applicable."},' +
                '"discountPercent": { "type": "number", "description": "Specifies the discount percent if applicable, or zero if not."}' +
            '},"required": ["code", "desc", "dueDateCalculation", "discountDateCalculation", "discountPercent"]}'
            );

        FunctionDefinition.Add('name', FunctionNameLbl);
        FunctionDefinition.Add('description', 'Call this function to create a new payment terms');
        FunctionDefinition.Add('parameters', ParametersDefinition);

        ToolDefinition.Add('type', 'function');
        ToolDefinition.Add('function', FunctionDefinition);

        exit(ToolDefinition);
    end;

    procedure Execute(Arguments: JsonObject): Variant
    var
        Code, Description, DueDateCalculation, DiscountDateCalculation, DiscountPercent : JsonToken;
    begin
        Arguments.Get('code', Code);
        Arguments.Get('desc', Description);
        Arguments.Get('dueDateCalculation', DueDateCalculation);
        Arguments.Get('discountDateCalculation', DiscountDateCalculation);
        Arguments.Get('discountPercent', DiscountPercent);

        TempPaymentTerms.Init();
        TempPaymentTerms.Code := Code.AsValue().AsCode();
        TempPaymentTerms.Description := Description.AsValue().AsText();
        Evaluate(TempPaymentTerms."Due Date Calculation", DueDateCalculation.AsValue().AsText());
        if DiscountDateCalculation.AsValue().AsText() <> '' then
            Evaluate(TempPaymentTerms."Discount Date Calculation", DiscountDateCalculation.AsValue().AsText());
        TempPaymentTerms."Discount %" := DiscountPercent.AsValue().AsDecimal();
        TempPaymentTerms.Insert();
        exit('Completed creating payment terms');
    end;

    procedure GetName(): Text
    begin
        exit(FunctionNameLbl);
    end;

    procedure GetPaymentTerms(var LocalPaymentTerms: Record "Payment Terms" temporary)
    begin
        LocalPaymentTerms.Copy(TempPaymentTerms, true);
    end;

    var
        TempPaymentTerms: Record "Payment Terms" temporary;
}