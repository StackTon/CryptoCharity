var CryptoCharity = artifacts.require("./CryptoCharity.sol");
var SafeMath = artifacts.require("./SafeMath.sol");
var SubjectLib = artifacts.require("./SubjectLib.sol");
var PersonLib = artifacts.require("./PersonLib.sol");

module.exports = function (deployer) {
  deployer.deploy(SubjectLib);
  deployer.link(SubjectLib, CryptoCharity);
  deployer.deploy(CryptoCharity, 10);
};
