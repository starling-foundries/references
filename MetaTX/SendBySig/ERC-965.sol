contract ChequeOperator {
    using SafeMath for uint256;
    using ECRecovery for bytes32;

    struct Agreement {
        uint256 totalPaid;
        address token;
        address payer;
        address beneficiary;
        bytes data;
    }
    mapping(bytes => Agreement) internal agreements;
    mapping(address => mapping(uint256 => bool)) public usedNonces; // For simple sendByCheque
    
    
    /* Simple send by Checque */
    
    function signerOfSimpleCheque(address _token, address _to, uint256 _amount, bytes _data, uint256 _nonce, bytes _sig) private pure returns (address) {
        return keccak256(abi.encodePacked(_token, _to, _amount, _data, _nonce)).toEthSignedMessageHash().recover(_sig);
    }
    
    function sendByCheque(address _token, address _to, uint256 _amount, bytes _data, uint256 _nonce, bytes _sig) public {
        require(_to != address(this));

        // Check if signature is valid and get signer's address
        address signer = signerOfSimpleCheque(_token, _to, _amount, _data, _nonce, _sig);
        require(signer != address(0));

        // Mark this cheque as used
        require (!usedNonces[signer][_nonce]);
        usedNonces[signer][_nonce] = true;

        // Send tokens
        ERC777Token token = ERC777Token(_token);
        token.operatorSend(signer, _to, _amount, _data, "");
    }


    /* Send by Aggreement */

    function signerOfAgreementCheque(bytes _agreementId, uint256 _amount, uint256 _fee, bytes _sig) private pure returns (address) {
        return keccak256(abi.encodePacked(_agreementId, _amount, _fee)).toEthSignedMessageHash().recover(_sig);
    }

    function createAgreement(bytes _id, address _token, address _payer, address _beneficiary, bytes _data) public {
        require(_beneficiary != address(0));
        require(_payer != address(0));
        //require(ERC777Token(_token));
        require(agreements[_id].beneficiary == address(0));
        agreements[_id] = Agreement({
            totalPaid: 0,
            token: _token,
            payer: _payer,
            beneficiary: _beneficiary,
            data: _data
        });
    } 

    function sendByAgreement(bytes _agreementId, uint256 _amount, uint256 _fee, bytes _sig) public returns (bool) {
        // Check if agreement exists
        Agreement storage agreement = agreements[_agreementId];
        require(agreement.beneficiary != address(0));

        // Check if signature is valid, remember last running sum
        address signer = signerOfAgreementCheque(_agreementId, _amount, _fee, _sig);
        require(signer == agreement.payer);

        // Calculate amount of tokens to be send
        uint256 amount = _amount.sub(agreement.totalPaid).sub(_fee);
        require(amount > 0);

        // If signer has less tokens that asked to transfer, we can transfer as much as he has already
        // and rest tokens can be transferred via same cheque but in another tx 
        // when signer will top up his balance.
        ERC777Token token = ERC777Token(agreement.token);
        if (amount > token.balanceOf(signer)) {
            amount = token.balanceOf(signer).sub(_fee);
        }

        // Increase already paid amount
        agreement.totalPaid = agreement.totalPaid.add(amount);

        // Send tokens
        token.operatorSend(signer, agreement.beneficiary, amount, agreement.data, "");
       
        if (_fee > 0) {
            token.operatorSend(signer, msg.sender, _fee, "", "");
        }

        return true;
    }
}

contract MyToken is ERC777Token {
    using ECRecovery for bytes32;
    mapping (address => mapping (uint256 => bool)) private usedNonces;

    constructor(address _checqueOperator) public {
        // Setting checquieOperator as default operator
        //require(ChequeOperator(_checqueOperator));
        mDefaultOperators.push(_checqueOperator);
        mIsDefaultOperator[_checqueOperator] = true;
    }
}