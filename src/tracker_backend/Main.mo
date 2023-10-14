import Time "mo:base/Time";
import Principal "mo:base/Principal";
import List "mo:base/List";

type ShipmentStatus = { #IN_TRANSIT; #DELIVERED };

type Shipment = {
    id: Nat;
    sender: Principal;
    receiver: Principal;
    status: ShipmentStatus;
    isPaid: Bool;
    pickupTime: Int;
    deliveryTime: ?Int;
};

type TypeShipment = {
    id: Nat;
    shipment: Shipment;
    status: ShipmentStatus;
    isPaid: Bool;
};

actor ShipmentManager {
    var shipments: List.List<Shipment> = List.nil<Shipment>();
    var typeShipments: List.List<TypeShipment> = List.nil<TypeShipment>();

    public func createShipment(sender: Principal, receiver: Principal) : async Nat {
        let index = List.length(shipments);
        let shipment = {
            id = index;
            sender = sender;
            receiver = receiver;
            status = #IN_TRANSIT;
            isPaid = false;
            pickupTime = Time.now();
            deliveryTime = null;
        };
        shipments := shipments # [shipment];
        typeShipments := List.append(typeShipments, [{ id = index; shipment = shipment; status = shipment.status; isPaid = shipment.isPaid }]);

        return index;
    };

    public func deliverShipment(sender: Principal, receiver: Principal, index: Nat) : async () {
        let shipment = shipments[index];
        assert(shipment.sender == sender);
        assert(shipment.receiver == receiver);
        assert(shipment.status == #IN_TRANSIT);

        shipment.status := #DELIVERED;
        shipment.deliveryTime := Time.now();

        typeShipments := List.append(typeShipments, [{ id = index; shipment = shipment; status = shipment.status; isPaid = shipment.isPaid }]);
    };

    public func getShipments(sender: Principal, receiver: Principal) : async [TypeShipment] {
        var filteredShipments: [TypeShipment] = [];
        for (shipment in typeShipments.vals()) {
            if (shipment.shipment.sender == sender && shipment.shipment.receiver == receiver) {
                filteredShipments := List.append(filteredShipments, [shipment]);
            }
        }
        return List.freeze(filteredShipments);
    };
};