table 50120 "SMHIT Planned Intervention"
{
    Caption = 'Intervention planifiée SMHIT';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'N° entrée';
            AutoIncrement = true;
        }
        field(2; "Convention No."; Code[20])
        {
            Caption = 'N° convention';
            TableRelation = "Service Contract Header"."Contract No.";
        }
        field(3; "Convention Version No."; Integer)
        {
            Caption = 'N° version convention';
        }
        field(4; "Convention Line No."; Integer)
        {
            Caption = 'N° ligne convention';
        }
        field(5; "Sequence No."; Integer)
        {
            Caption = 'N° séquence';
        }
        field(6; "Customer Code"; Code[20])
        {
            Caption = 'Code client';
            TableRelation = Customer."No.";
        }
        field(7; "Ship-to Code"; Code[20])
        {
            Caption = 'Code livraison (site)';
            TableRelation = "Ship-to Address".Code WHERE("Customer No." = FIELD("Customer Code"));
        }
        field(8; "Service Item No."; Code[20])
        {
            Caption = 'N° article service';
        }
        field(9; "Service Description"; Text[100])
        {
            Caption = 'Description service';
        }
        field(10; "Initial Theoretical Date"; Date)
        {
            Caption = 'Date théorique initiale';
        }
        field(11; "Current Planned Date"; Date)
        {
            Caption = 'Date planifiée courante';
        }
        field(12; "Actual Date"; Date)
        {
            Caption = 'Date de réalisation';
        }
        field(13; "Previous Theoretical Date"; Date)
        {
            Caption = 'Date théorique précédente';
        }
        field(14; "Bucket Year-Month"; Code[7])
        {
            Caption = 'Bucket Année-Mois';
        }
        field(15; "Theoretical Month"; Code[7])
        {
            Caption = 'Mois théorique';
        }
        field(16; "Overflow"; Boolean)
        {
            Caption = 'Débordement';
        }
        field(17; "Status"; Enum "SMHIT Intervention Status")
        {
            Caption = 'Statut';
        }
        field(18; "Miss Cause"; Text[100])
        {
            Caption = 'Cause de manquement';
        }
        field(19; "Nb Postponements"; Integer)
        {
            Caption = 'Nb reports';
        }
        field(20; "Last Postponement No."; Code[20])
        {
            Caption = 'Dernier report N°';
        }
        field(21; "Service Order No."; Code[20])
        {
            Caption = 'N° ordre de service';
            TableRelation = "Service Header"."No." WHERE("Document Type" = CONST(Order));
        }
        field(22; "Service Order Line No."; Integer)
        {
            Caption = 'N° ligne ordre de service';
        }
        field(23; "Service Item Line No."; Integer)
        {
            Caption = 'N° ligne article service';
        }
        field(24; "Assigned Technician"; Code[20])
        {
            Caption = 'Technicien affecté';
            TableRelation = Resource."No." WHERE(Type = CONST(Person));
        }
        field(25; "Estimated Duration (h)"; Decimal)
        {
            Caption = 'Durée estimée (h)';
        }
        field(26; "Actual Duration (h)"; Decimal)
        {
            Caption = 'Durée réelle (h)';
        }
        field(27; "Created By"; Code[50])
        {
            Caption = 'Créé par';
        }
        field(28; "Created At"; DateTime)
        {
            Caption = 'Date création';
        }
        field(29; "Modified By"; Code[50])
        {
            Caption = 'Modifié par';
        }
        field(30; "Modified At"; DateTime)
        {
            Caption = 'Date modification';
        }
        field(31; "Locked"; Boolean)
        {
            Caption = 'Verrouillée';
        }
        field(32; "Comments"; Text[250])
        {
            Caption = 'Commentaires';
        }
        field(33; "Convention Status"; Text[30])
        {
            Caption = 'Statut convention';
        }
        field(34; "Convention Type"; Text[30])
        {
            Caption = 'Type convention';
        }
        field(35; "Convention Locked (Planning)"; Boolean)
        {
            Caption = 'Convention verrouillée (planif.)';
        }
        field(36; "Service Order Type"; Text[30])
        {
            Caption = 'Type commande';
        }
        field(37; "Site Geographic Zone"; Code[20])
        {
            Caption = 'Zone géographique site';
        }
        field(38; "Site Name"; Text[100])
        {
            Caption = 'Nom site';
        }
        field(39; "Selected"; Boolean)
        {
            Caption = 'Sélectionnée';
        }
        field(40; "Route Sheet No."; Code[20])
        {
            Caption = 'N° feuille de route';
        }
        field(41; "Route Sheet Line No."; Integer)
        {
            Caption = 'N° ligne feuille de route';
        }
        field(42; "Route Sheet Date"; Date)
        {
            Caption = 'Date feuille de route';
        }
        field(43; "Route Sheet Status"; Text[30])
        {
            Caption = 'Statut feuille de route';
        }
        field(44; "Invoice No."; Code[20])
        {
            Caption = 'N° facture';
        }
        field(45; "Invoicing Date"; Date)
        {
            Caption = 'Date facturation';
        }
    }

    keys
    {
        key(PK; "Entry No.") { Clustered = true; }
        key(K2; "Convention No.", "Convention Version No.", "Convention Line No.", "Bucket Year-Month") { }
        key(K3; "Service Order No.") { }
        key(K4; "Route Sheet No.", "Route Sheet Line No.") { }
    }
}
