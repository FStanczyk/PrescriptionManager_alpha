// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract PrescriptionManager{
    //True if is admin - False if it's not
    mapping (address=>bool) public admin; 
    mapping (address=>bool) public doctor;
    mapping (uint32=>string) public drugs;
    uint32 public drugID;
    uint256 public prescriptionId;
    address public owner;

    constructor(){
        //Contract creator is anadminand owner by definition
        admin[msg.sender] = true;
        owner = msg.sender;
        drugID = 0;
        prescriptionId = 0;
    }


    struct Prescription{
        address doctor; //Doctor that issued the prescription
        address client; //patient address
        string drug;
        uint256 id;
        bool used ;
        uint32 dose;
        string doseInfo; //info about dose
    }

    Prescription[] public prX;
    mapping (address=>Prescription[]) public patientPrxList;
    modifier onlyAdmin{
        require(admin[msg.sender] == true, "You have to be an Admin to use this function");
        _;
    }
    modifier onlyDoctor{
        require(doctor[msg.sender] == true, "You have to be a Doctor to use this function");
        _;
    }

    //this function should be used to assert yourself that given ID is indeed the drug you want.
    //full list of drugs with ID's should be stored in the external database
    function checkDrug(uint32 id)view external returns(string memory){
        return drugs[id];
    }
    function giveAdminPermission(address _address) external onlyAdmin{
        //address must not be an admin already
        require( !admin[_address], "This address is already an admin");

        admin[_address] = true;
    }

    function removeAdminPermission(address _address) external onlyAdmin{
        require(admin[_address] == true, "This address is already not an admin");
        //You can't remove admin permissions from the owner
        require(_address != owner, "You have no permission to do remove permission from the owner");

        admin[_address] = false;
    }

    function giveDoctorPermission(address _address) external onlyAdmin{
        require(doctor[_address] == false, "This address is already an admin");

        doctor[_address] = true;
    }
    function removeDoctorPermission(address _address) external onlyAdmin{
        require(doctor[_address] == true, "This address is already not an admin");

        doctor[_address] = false;
    }

    function addDrug(string memory _drugName) external onlyAdmin{
        //adds a drug to the drug list
        drugs[drugID] = _drugName;
        drugID++;
    }

    //Be aware! this function does not add drugID, it replaces already existing drug or empty ID
    //after one was deleted. Should be used only to fill holes in the ID list or correct mistypings.
    function addDrugManuallyId(string memory _drugName, uint32 _id) external onlyAdmin{
        //adds a drug to the drug list
        drugs[_id] = _drugName;
    }

    function removeDrug(uint32 _id) external onlyAdmin{
        //adds a drug to the drug list
        drugs[_id] = "";
    }

    //here doctor can issue a prescription
    function issuePrescription(address _address, uint32 _drugId, uint32 _dose, string memory _doseInfo) external onlyDoctor{
        Prescription memory randomPrx;

        randomPrx.client = _address;
        randomPrx.doctor = msg.sender;
        randomPrx.drug = drugs[_drugId];
        randomPrx.dose = _dose;
        randomPrx.doseInfo = _doseInfo;
        randomPrx.id = prescriptionId;
        randomPrx.used = false;
        prX.push(randomPrx);
        patientPrxList[_address].push(randomPrx);
        prescriptionId++;
    }

    //Patient will have to use that functionwhen buying drug (probably some mobile contactless app)
    function usePrescription(uint32 _patientPrxId) external{
        require(patientPrxList[msg.sender][_patientPrxId].used == false, "You have already used this prescription.");
        patientPrxList[msg.sender][_patientPrxId].used = true;
    }
}
