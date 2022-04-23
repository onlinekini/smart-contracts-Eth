// SPDX-License-Identifier: UNLICENSED
pragma solidity > 0.8.10;

// Used by the university to register, recognize and deregister colleges
contract CollegeManagement {

    address adminAddress; // University admin address
    mapping(address => College) collegesUnderUniversity; // The mapping between the address and the college under the university
    mapping(address => mapping(string => Student)) collegeStudents; // mapping between college and students

    // College Struct
    struct College {
        string name;
        address add; // It is assumed, that the admin address and college address are the same
        string regNum;
        bool isBlocked;
        uint studentCount;
    }
     
    // Student information struct
    struct Student {
        string name;
        uint phoneNumber;
        string courseEnrolled;
    }

    // Constructor, Identify the Admin at the start
    constructor() {
        adminAddress = msg.sender;
    }

    modifier onlyAdmin() {
        require(msg.sender == adminAddress, " Authorized only for University Admin ");
        _;
    }

    modifier onlyCollegeAdmin(address _collAddr) {
        require(msg.sender == collegesUnderUniversity[_collAddr].add, " Authorized to College Admin ");
        _;
    }

    modifier allowUnblocked(address _collAddr) {
        require(!collegesUnderUniversity[_collAddr].isBlocked, " College Blocked from adding Students ");
        _;
    }

    // Register College, To be called by Uni Admin only
    function registerCollege(string memory _collegeName, address _add, string memory _regNo) public onlyAdmin() {    
        // Set the basic initialization values. College is allowed to add students & student count = 0
        College memory newCollege = College(_collegeName, _add, _regNo, false, 0);
        collegesUnderUniversity[_add] = newCollege;
        // College registered
    }

    // view college details -- Any one  
    function viewCollege(address _collAddr) public view returns (address collegeAddr, string memory collegeName, string memory regNo, uint numOfStudents, string memory status) {
        College memory coll = collegesUnderUniversity[_collAddr];
        return (coll.add, coll.name, coll.regNum, coll.studentCount, (coll.isBlocked ? "Blocked" : "Unblocked"));
    } 

    // Block College from doing any admissions, Uni Admin only
    function blockCollege(address _collAddress) public onlyAdmin() {
        College memory coll = collegesUnderUniversity[_collAddress];
        coll.isBlocked = true;
        collegesUnderUniversity[_collAddress] = coll;
    }
 
    //Unblock College, Uni Admin only
    function unblockCollege(address _collAddress) public onlyAdmin() {
        College memory coll = collegesUnderUniversity[_collAddress];
        coll.isBlocked = false;
        collegesUnderUniversity[_collAddress] = coll;
    }

    // Add Student to college - College Admin, Assuming Name as the unique identifier.
    function enrollStudent(address _add, string memory _sName, uint _phoneNo, string memory courseName) public  onlyCollegeAdmin(_add) allowUnblocked(_add) { 
        // Set the basic initialization values. College is allowed to add students & student count = 0
        Student memory newStudent = Student(_sName, _phoneNo, courseName);
        collegesUnderUniversity[_add].studentCount++;
        collegeStudents[_add][_sName] = newStudent;
    }

    // View student information -- Anyone
    function viewStudentInfo(string memory _sName) public view returns (string memory name, uint phoneNo, string memory courseName) {
        address collAddr = msg.sender; 
        Student memory student = collegeStudents[collAddr][_sName];
        return (student.name, student.phoneNumber, student.courseEnrolled); 
    }

    // change student course -- College Admin
    function changeStudentCourse(string memory _sName, string memory _newCourse) public onlyCollegeAdmin(msg.sender) allowUnblocked(msg.sender) {
        address collAddr = msg.sender;
        Student memory student = collegeStudents[collAddr][_sName];
        student.courseEnrolled = _newCourse;
        collegeStudents[collAddr][_sName] = student;
    }

}
