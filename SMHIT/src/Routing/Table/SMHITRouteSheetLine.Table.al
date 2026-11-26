table 50154 "SMHIT Route Sheet Line"
{
    Caption = 'Ligne feuille de route SMHIT';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Version Line No."; Integer)
        {
            Caption = 'Version ligne N°';
            AutoIncrement = true;
        }
        field(2; "Date"; Date)
        {
            Caption = 'Date';
        }
        field(3; "Half Day"; Option)
        {
            Caption = 'Demi-journée';
            OptionMembers = "Matin","Après-midi","Journée complète";
        }
        field(4; "Description"; Text[100])
        {
            Caption = 'Description';
        }
        field(5; "Technician Version No."; Code[20])
        {
            Caption = 'Version N° technicien';
        }
        field(6; "Technician No."; Code[20])
        {
            Caption = 'N° technicien';
            TableRelation = Resource."No." WHERE(Type = CONST(Person));
        }
        field(7; "Technician Name"; Text[100])
        {
            Caption = 'Nom technicien';
        }
        field(8; "Truck"; Code[20])
        {
            Caption = 'Camion';
        }
        field(9; "Truck Description"; Text[100])
        {
            Caption = 'Description camion';
        }
        field(10; "Status"; Option)
        {
            Caption = 'Statut';
            OptionMembers = "Planifiée","En cours","Terminée","Annulée";
        }
        field(11; "Status Date/Time"; DateTime)
        {
            Caption = 'Date/Heure statut';
        }
        field(12; "Planned Start Time"; Time)
        {
            Caption = 'Heure début prévue';
        }
        field(13; "Planned End Time"; Time)
        {
            Caption = 'Heure fin prévue';
        }
        field(14; "Actual Start"; DateTime)
        {
            Caption = 'Début réel';
        }
        field(15; "Actual End"; DateTime)
        {
            Caption = 'Fin réelle';
        }
        field(16; "Notification Sent"; Boolean)
        {
            Caption = 'Notification envoyée';
        }
        field(17; "Notification Date/Time"; DateTime)
        {
            Caption = 'Date/Heure notification';
        }
        field(18; "Notification Channel"; Text[30])
        {
            Caption = 'Canal notification';
        }
        field(19; "Nb Visits"; Integer)
        {
            Caption = 'Nb visites';
        }
        field(20; "Visits Done"; Integer)
        {
            Caption = 'Visites faites';
        }
        field(21; "Visits Missed"; Integer)
        {
            Caption = 'Visites manquées';
        }
        field(22; "Total Kilometers"; Decimal)
        {
            Caption = 'Kilomètres totaux';
        }
        field(23; "Odometer Start"; Decimal)
        {
            Caption = 'Compteur début';
        }
        field(24; "Odometer End"; Decimal)
        {
            Caption = 'Compteur fin';
        }
        field(25; "Vehicle Cost Rate per Km"; Decimal)
        {
            Caption = 'Taux véhicule/km';
        }
        field(26; "Vehicle Cost"; Decimal)
        {
            Caption = 'Coût véhicule';
        }
        field(27; "Reason"; Text[100])
        {
            Caption = 'Motif';
        }
        field(28; "Comments"; Text[250])
        {
            Caption = 'Commentaires';
        }
        field(29; "Circuit Code"; Code[20])
        {
            Caption = 'Code circuit';
        }
        field(30; "Circuit Description"; Text[100])
        {
            Caption = 'Description circuit';
        }
        field(31; "Service Order No."; Code[20])
        {
            Caption = 'N° ordre de service (visite)';
            TableRelation = "Service Header"."No." WHERE("Document Type" = CONST(Order));
        }
        field(32; "Intervention Entry No."; Integer)
        {
            Caption = 'N° entrée intervention';
            TableRelation = "SMHIT Planned Intervention"."Entry No.";
        }
        field(33; "Created By"; Code[50])
        {
            Caption = 'Créé par';
        }
        field(34; "Created At"; DateTime)
        {
            Caption = 'Date/Heure création';
        }
        field(35; "Closed By"; Code[50])
        {
            Caption = 'Clôturé par';
        }
        field(36; "Closed At"; DateTime)
        {
            Caption = 'Date/Heure clôture';
        }
    }

    keys
    {
        key(PK; "Version Line No.") { Clustered = true; }
        key(K2; "Service Order No.") { }
        key(K3; "Intervention Entry No.") { }
        key(K4; "Date", "Technician No.") { }
    }
}
