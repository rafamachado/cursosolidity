// SPDX-License-Identifier: MIT
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

pragma solidity 0.8.19;

// Endereco:  0x89A2E711b2246B586E51f579676BE2381441A0d0

contract Cadastro {

    struct Cliente {
        uint256 id;
        string primeiroNome;
        string sobreNome;
        address payable endereco; //0x0
        bytes32 hashConta; // 0x0  
        bool existe; //false
    }

    IERC20 public token; 
    uint256 public totalClientes;

    Cliente[] public clientes;

    modifier somenteCadastroRealizado() {        
        require(clientes.length == 0, "Cadastro existente");
        _;
    }

    function addCliente(
        string memory _primeiroNome,
        string memory _sobreNome,        
        string memory _agencia,
        string memory _conta
    ) external returns (bool) {
        string memory strTemp = string.concat(_agencia, _conta);
        bytes memory bTemp = bytes(strTemp);
        bytes32 hashTemp = keccak256(bTemp);

        Custodia custodiaTemp = new Custodia(hashTemp);

        Cliente memory cliente = Cliente(totalClientes, _primeiroNome, _sobreNome, payable(address(custodiaTemp)), hashTemp, true);
        totalClientes++;
   
        clientes.push(cliente);
        
        return true;
    }

    function getClientePeloId(uint256 _id) external view returns (Cliente memory cliente_, bool existe) {
        cliente_ = clientes[_id];
        existe = cliente_.existe;
        return (cliente_, existe);
    }

    function meuSaldo(address enderecoContrato) public view returns(uint){
        return enderecoContrato.balance;
    }

    function saldoAtualContrato() public view returns (uint) {
        return address(this).balance;
    }

    function gerarTokenParaEuCliente(address _enderecoToken) 
    external 
    somenteCadastroRealizado()
    returns(bool) {
        token = IERC20(_enderecoToken);
        return true;
    }

}

contract Custodia {
    bytes32 public hashConta;

    event EtherRecebido();

    constructor(bytes32 _hashConta) {
        hashConta = _hashConta;
    }

    receive() external payable {
        emit EtherRecebido();
    }
    
}
