var CryptoCharity = artifacts.require("./CryptoCharity.sol");
var SafeMath = artifacts.require("./SafeMath.sol");
var SubjectLib = artifacts.require("./SubjectLib.sol");
var PersonLib = artifacts.require("./PersonLib.sol");

module.exports = function (deployer) {
  
  deployer.deploy(SafeMath);
  deployer.deploy(PersonLib);
  deployer.deploy(SubjectLib);
  deployer.link(SafeMath, CryptoCharity);
  deployer.link(SubjectLib, CryptoCharity);
  deployer.link(PersonLib, CryptoCharity);
  deployer.deploy(CryptoCharity, 10);
};
