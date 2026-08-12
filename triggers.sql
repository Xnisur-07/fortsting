DELIMITER //

-- Trigger 1: Stock increases when a donation of items is recorded
CREATE TRIGGER trg_after_donation_insert
AFTER INSERT ON Donation_Item
FOR EACH ROW
BEGIN
    UPDATE Relief_Item
    SET Quantity_Available = Quantity_Available + NEW.Quantity_Donated
    WHERE Item_ID = NEW.Item_ID;
END //

-- Trigger 2: Block distribution if stock is insufficient
CREATE TRIGGER trg_before_distribution_insert
BEFORE INSERT ON Distribution_Details
FOR EACH ROW
BEGIN
    DECLARE available_qty DECIMAL(10,2);

    SELECT Quantity_Available INTO available_qty
    FROM Relief_Item
    WHERE Item_ID = NEW.Item_ID;

    IF available_qty IS NULL OR available_qty < NEW.Quantity_Given THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Insufficient stock available for this item!';
    END IF;
END //

-- Trigger 3: Stock decreases after a distribution is recorded
CREATE TRIGGER trg_after_distribution_insert
AFTER INSERT ON Distribution_Details
FOR EACH ROW
BEGIN
    UPDATE Relief_Item
    SET Quantity_Available = Quantity_Available - NEW.Quantity_Given
    WHERE Item_ID = NEW.Item_ID;
END //

-- Trigger 4: Family.Total_Members auto-updates on member insert
CREATE TRIGGER trg_after_member_insert
AFTER INSERT ON Family_Member
FOR EACH ROW
BEGIN
    UPDATE Family
    SET Total_Members = (
        SELECT COUNT(*)
        FROM Family_Member
        WHERE Family_ID = NEW.Family_ID
    )
    WHERE Family_ID = NEW.Family_ID;
END //

-- Trigger 5: Family.Total_Members auto-updates on member delete
CREATE TRIGGER trg_after_member_delete
AFTER DELETE ON Family_Member
FOR EACH ROW
BEGIN
    UPDATE Family
    SET Total_Members = (
        SELECT COUNT(*)
        FROM Family_Member
        WHERE Family_ID = OLD.Family_ID
    )
    WHERE Family_ID = OLD.Family_ID;
END //

-- Trigger 6: Relief_Package.Total_Cost auto-recalculates on Package_Item insert
CREATE TRIGGER trg_after_packageitem_insert
AFTER INSERT ON Package_Item
FOR EACH ROW
BEGIN
    UPDATE Relief_Package
    SET Total_Cost = (
        SELECT COALESCE(SUM(pi.Quantity_Per_Package * ri.Unit_Price), 0)
        FROM Package_Item pi
        JOIN Relief_Item ri ON pi.Item_ID = ri.Item_ID
        WHERE pi.Package_ID = NEW.Package_ID
    )
    WHERE Package_ID = NEW.Package_ID;
END //

-- Trigger 7: Relief_Package.Total_Cost auto-recalculates on Package_Item delete
CREATE TRIGGER trg_after_packageitem_delete
AFTER DELETE ON Package_Item
FOR EACH ROW
BEGIN
    UPDATE Relief_Package
    SET Total_Cost = (
        SELECT COALESCE(SUM(pi.Quantity_Per_Package * ri.Unit_Price), 0)
        FROM Package_Item pi
        JOIN Relief_Item ri ON pi.Item_ID = ri.Item_ID
        WHERE pi.Package_ID = OLD.Package_ID
    )
    WHERE Package_ID = OLD.Package_ID;
END //

-- Trigger 8: Audit log entry whenever a Family record is updated
CREATE TRIGGER trg_family_audit_update
AFTER UPDATE ON Family
FOR EACH ROW
BEGIN
    INSERT INTO Audit_Log (
        Table_Name,
        Record_ID,
        Action_Type,
        Changed_By,
        Old_Value,
        New_Value
    )
    VALUES (
        'Family',
        OLD.Family_ID,
        'UPDATE',
        CURRENT_USER(),
        CONCAT(
            'Card_Status: ', OLD.Card_Status,
            ', Priority: ', OLD.Priority_Level
        ),
        CONCAT(
            'Card_Status: ', NEW.Card_Status,
            ', Priority: ', NEW.Priority_Level
        )
    );
END //

DELIMITER ;
