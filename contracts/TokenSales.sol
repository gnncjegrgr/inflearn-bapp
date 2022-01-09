pragma solidity ^0.5.0;

import "openzeppelin-solidity/contracts/token/ERC721/ERC721Full.sol";

contract TokenSales {
  ERC721Full public nftAddress; //nft의 address

  mapping(uint256=>uint256)public tokenPrice; // tokenId를 입력하면 얼마의 가격인지 알려주는 매핑

  constructor(address _tokenAddress) public{
      nftAddress = ERC721Full(_tokenAddress); //nft address를 설정해준다.
  }

  function setForSale(uint256 _tokenId, uint256 _price)public{
    //tokenId, price를 입력받고 해당 tokenId를 가지는 토큰의 가격을 설정해준다.
    address tokenOwner = nftAddress.ownerOf(_tokenId);//해당 토큰아이디를 가지는 토큰의 소유자 초기화
    require(tokenOwner == msg.sender , "caller is not token ower");//소유자가 자신의 토큰을 판매중이라고 설정해야함.
    require(_price>0, "price is zero or lower");//price가 0보다 커야한다.
    require(nftAddress.isApprovedForAll(tokenOwner, address(this)), "token owner did not approve TokenSales contract");
    //tokenOwner가 컨트랙트에게 판매 권한을 줘야한다.
    tokenPrice[_tokenId]=_price;
    // tokenPrice를 설정한다.
  }
  
  function purchaseToken(uint _tokenId)public payable{//토큰을 구매한다.
    uint256 price = tokenPrice[_tokenId];
    // 해당 토큰아이디를 가지는 토큰의 가격을 초기화한다.
    address tokenSeller = nftAddress.ownerOf(_tokenId);
    // 토큰의 판매자를 초기화한다.
    require(msg.value>=price,"caller sent klay lower than price");
    // msg.value가 price보다 커야한다.
    require(msg.sender!=tokenSeller, "caller is token seller");
    // 판매자와 구매자가 일치하면 안된다.
    address payable payableTokenSeller = address(uint160(tokenSeller));
    // 이건 잘 모르겠다
    payableTokenSeller.transfer(msg.value);
    // 이것도 잘 모르겠다.
    nftAddress.safeTransferFrom(tokenSeller, msg.sender, _tokenId);
    // tokenSeller가 msg.sender 에게 _tokenId의 소유권을 바꿔준다.
    tokenPrice[_tokenId]=0;
  }

  function removeTokenOnSale(uint256[] memory tokenIds)public{
    require(tokenIds.length>0,"tokenIds is empty");
    // tokenIds의 길이가 0보다 커야한다.
    for(uint i=0;i<tokenIds.length;i++){
      uint256 tokenId = tokenIds[i]; // 
      address tokenSeller = nftAddress.ownerOf(tokenId);
      require(msg.sender == tokenSeller, "caller is not token seller");
      tokenPrice[tokenId]=0;
    }
  }

}