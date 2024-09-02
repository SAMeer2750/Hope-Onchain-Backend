// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract Vault is Ownable{

    constructor(address owner) Ownable(owner) {}

    fallback() external payable {}

}