// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

/**
 * @title TPOA (tokens proof of attendance)
 * @version: v1.0
 * TopacioTrade Contracts (last updated v1.0.1)
 * Network: Polygon
 */

/**
 * @dev If you want to participate in or support decentralized projects like this
 * you can visit https://www.topacio.trade
 */

/// @custom:security-contact jv@topacio.trade
contract TPoa is
    ERC721,
    ERC721Enumerable,
    ERC721URIStorage,
    ERC721Burnable,
    Ownable
{
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;
    string public _baseURI_ipfs = "https://ipfs.io/ipfs/";
    bool public isActive;
    mapping(address => uint256) private _administradores;
    mapping(uint256 => uint256) public _metadata;
    // A mapping of token owners Holders
    mapping(uint256 => address[]) public ownersHolders;
    mapping(uint256 => string) public hash_ipfs_img;

    struct Burned {
        uint256 a;
        address w;
    }

    mapping(uint256 => Burned[]) public burned;
    mapping(address => uint256) private holderList;
    uint256 private holderCtr;
    uint256 public burnedCtr;

    // address, tokenId
    event NftBurnned(address, uint256);

    event NewMint(address, uint256);

    modifier onlyAdministrator() {
        require(_administradores[msg.sender] != 0, "you are not administrator");
        _;
    }

    constructor(string memory __name, string memory __symbol)
        ERC721(__name, __symbol)
    {
        _administradores[msg.sender] = 1;
        isActive = true;
    }

    function getHashImg(uint256 _idTkn) public view returns (string memory) {
        return hash_ipfs_img[_idTkn];
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseURI_ipfs;
    }

    function updateBaseURI(string memory _uri_base_ipfs) public onlyOwner {
        _baseURI_ipfs = _uri_base_ipfs;
    }

    function safeMint(
        address to,
        string memory uri,
        string memory hash_img
    ) public onlyAdministrator {
        require(isActive == true, "It's not active");
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
        hash_ipfs_img[tokenId] = hash_img;
        emit NewMint(to, tokenId);
    }

    function getHoldersCount() public view returns (uint256) {
        return holderCtr;
    }

    function getHolders() public view returns (address[] memory) {
        address[] memory holders_w = new address[](holderCtr);
        uint256 pp = 0;
        for (uint256 zz = 0; zz < ownersHolders[0].length; zz++) {
            if (ownersHolders[0][zz] != address(0)) {
                holders_w[pp] = (ownersHolders[0][zz]);
                pp++;
            }
        }

        return holders_w;
    }

    function getTokensHolder(address _wallet)
        public
        view
        returns (uint256[] memory)
    {
        require(_wallet != address(0), "wallet can't be zero");
        uint256 balanceW = balanceOf(_wallet);

        uint256[] memory tkns_w = new uint256[](balanceW);
        if (balanceW > 0) {
            for (uint256 x = 0; x < balanceW; x++) {
                uint256 tId = tokenOfOwnerByIndex(_wallet, x);
                tkns_w[x] = (tId);
            }
        }

        return tkns_w;
    }

    function removeOfHolders(address _w) internal {
        for (uint256 z = 0; z < ownersHolders[0].length; z++) {
            if (ownersHolders[0][z] == _w) {
                delete (ownersHolders[0][z]);
                if (holderCtr > 0) {
                    holderCtr--;
                }
            }
        }
    }

    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId,
        uint256 batchSize
    ) internal override(ERC721, ERC721Enumerable) {
        require(from == address(0), "can't be transfer");
        bool isZero = (to == address(0));

        if (
            from != address(0) && from != address(this) && balanceOf(from) == 1
        ) {
            removeOfHolders(from);
        }

        // nuevo Holder
        if (!isZero && balanceOf(to) == 0) {
            ownersHolders[0].push(to);
            holderCtr++;
        }

        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    function _burn(uint256 tokenId)
        internal
        override(ERC721, ERC721URIStorage)
    {
        super._burn(tokenId);
        burnedCtr++;
        burned[burnedCtr].push(Burned(burnedCtr, msg.sender));
        emit NftBurnned(msg.sender, tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function updateTokenURI(uint256 tokenId, string memory _tokenURI)
        external
        onlyAdministrator
    {
        super._setTokenURI(tokenId, _tokenURI);
    }

    function checkAdmin(address admin)
        public
        view
        onlyAdministrator
        returns (uint256)
    {
        return _administradores[admin];
    }

    function addAdmin(address admin) public onlyOwner {
        _administradores[admin] = 1;
    }

    function removeAdmin(address admin) public onlyOwner {
        delete (_administradores[admin]);
    }

    function lastToken() public view returns (uint256) {
        require(_tokenIdCounter.current() > 0, "no exist nfts until now");
        return _tokenIdCounter.current() - 1;
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}

contract AdministratorTPoa {
    TPoa[] tpoas;
    string __name;
    string __symbol_prefix;
    uint256 control_tpoas;
    uint256 block_minutes_active;
    uint256 public totalMint;
    address owner;

    mapping(address => mapping(uint256 => uint256[])) public TPoaInAddress;
    mapping(address => mapping(uint256 => string)) public TPoaMetaData;
    mapping(address => string) public TPoaImgs;
    // Indexed parameters helps you filter the logs by the indexed parameter
    event EvtMint(address indexed _to);
    event NewMint(address indexed _to, uint256 tkn, address contractTpoa);

    modifier onlyOwner() {
        require(msg.sender == owner, "you are not owner");
        _;
    }

    constructor(string memory name_collectrion, string memory symbol_collection)
        payable
    {
        __name = name_collectrion;
        __symbol_prefix = symbol_collection;
        owner = msg.sender;
    }

    function isOwner() public view returns (bool) {
        return owner == msg.sender;
    }

    function addNewTPoa(
        string memory __uri_hash_meta,
        string memory __hash_img,
        uint256 __minutes_active
    ) public payable onlyOwner {
        TPoa newTPoa = new TPoa(__name, __symbol_prefix);
        tpoas.push(newTPoa);
        TPoaImgs[address(newTPoa)] = __hash_img;
        TPoaMetaData[address(newTPoa)][control_tpoas] = __uri_hash_meta;
        block_minutes_active = block.timestamp + (__minutes_active * 1 minutes);
        control_tpoas++;
    }

    function getImageHashTpoa(address _tpoa_address)
        public
        view
        returns (string memory)
    {
        return TPoaImgs[address(_tpoa_address)];
    }

    function mintExternal(address destine) external payable onlyOwner {
        require(
            block_minutes_active > block.timestamp,
            "Tpoa the time has finished"
        );
        require(tpoas.length > 0, "need to have some collection created");
        require(
            tpoas[control_tpoas - 1].balanceOf(destine) == 0,
            "this address has this tpoa"
        );
        require(
            address(destine).balance > 0,
            "Needed some Gas fees."
        );

        tpoas[control_tpoas - 1].safeMint(
            destine,
            TPoaMetaData[address(tpoas[control_tpoas - 1])][control_tpoas - 1],
            TPoaImgs[address(tpoas[control_tpoas - 1])]
        );

        uint256 idTk = tpoas[control_tpoas - 1].lastToken();
        TPoaInAddress[destine][control_tpoas - 1].push(idTk);
        emit NewMint(destine, idTk, address(tpoas[control_tpoas - 1]));
        totalMint++;
    }

    function checking() public {
        require(
            block_minutes_active > block.timestamp,
            "Tpoa the time has finished"
        );
        require(tpoas.length > 0, "need to have some collection created");
        require(
            tpoas[control_tpoas - 1].balanceOf(msg.sender) == 0,
            "this address has this tpoa"
        );
        emit EvtMint(msg.sender);
    }

    function mintPublic() public payable {
        require(
            block_minutes_active > block.timestamp,
            "Tpoa the time has finished"
        );
        require(tpoas.length > 0, "need to have some collection created");
        require(
            tpoas[control_tpoas - 1].balanceOf(msg.sender) == 0,
            "this address has this tpoa"
        );

        tpoas[control_tpoas - 1].safeMint(
            msg.sender,
            TPoaMetaData[address(tpoas[control_tpoas - 1])][control_tpoas - 1],
            TPoaImgs[address(tpoas[control_tpoas - 1])]
        );

        uint256 idTk = tpoas[control_tpoas - 1].lastToken();
        TPoaInAddress[msg.sender][control_tpoas - 1].push(idTk);
        totalMint++;
    }

    function mintTPoa(
        address _to,
        string memory _uri,
        string memory hash_img
    ) public payable onlyOwner {
        require(
            tpoas[control_tpoas - 1].balanceOf(_to) == 0,
            "this address has this tpoa"
        );
        tpoas[control_tpoas - 1].safeMint(_to, _uri, hash_img);
        uint256 idTk = tpoas[control_tpoas - 1].lastToken();
        TPoaInAddress[_to][control_tpoas - 1].push(idTk);
        totalMint++;
    }

    function getCountsTPoaOfCollections(uint256 _n)
        public
        view
        returns (uint256)
    {
        return tpoas[_n].totalSupply();
    }

    function getTPoaCollections() public view returns (TPoa[] memory) {
        return tpoas;
    }

    function getCountTPoaCollections() public view returns (uint256) {
        return tpoas.length;
    }
}
