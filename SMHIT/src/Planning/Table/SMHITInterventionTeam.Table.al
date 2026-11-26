table 50124 "SMHIT Intervention Team"
{
    Caption = 'Équipe d''intervention SMHIT';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Intervention Entry No."; Integer)
        {
            Caption = 'N° entrée intervention';
            TableRelation = "SMHIT Planned Intervention"."Entry No.";
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'N° ligne';
        }
        field(3; "Resource No."; Code[20])
        {
            Caption = 'N° technicien';
            TableRelation = Resource."No." WHERE(Type = CONST(Person));
        }
        field(4; "Resource Name"; Text[100])
        {
            Caption = 'Nom technicien';
        }
        field(5; "Estimated Hours"; Decimal)
        {
            Caption = 'Heures estimées';
        }
        field(6; "Actual Hours"; Decimal)
        {
            Caption = 'Heures réelles sur site';
        }
        field(7; "Hourly Cost Rate"; Decimal)
        {
            Caption = 'Taux horaire chargé';
        }
        field(8; "Labor Cost"; Decimal)
        {
            Caption = 'Coût main d''œuvre';
            CalcFormula = Sum("SMHIT Intervention Team"."Actual Hours" * "SMHIT Intervention Team"."Hourly Cost Rate");
        }
    }

    keys
    {
        key(PK; "Intervention Entry No.", "Line No.") { Clustered = true; }
    }
}
