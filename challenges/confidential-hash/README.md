[confidential-hash](https://quillctf.super.site/challenges/quillctf-challenges/ctf02)

# Solution:
* information is not private on the blockchain
* we can get the memory from specific slots using the alchemy API
* should get memory from slot 4 and 9
```
const options = {
  method: 'POST',
  headers: {accept: 'application/json', 'content-type': 'application/json'},
  body: JSON.stringify({
    id: 1,
    jsonrpc: '2.0',
    method: 'eth_getStorageAt',
    params: ['0xA37CE002C8167E65540079fcf6de44b02CA93a9C', '0x09', 'latest']
  })
};

fetch('https://eth-goerli.g.alchemy.com/v2/docs-demo', options)
  .then(response => response.json())
  .then(response => console.log(response))
  .catch(err => console.error(err));
```
* Deployed Confidential on Goerli at 0xA37CE002C8167E65540079fcf6de44b02CA93a9C
* 0x9371c02eefbd06113fb7e1ce6d27c3c7f6c8fc4d1b5f5f6b2620cd04d1610e3f at slot 4
* 0x23884ae3f28ba61fa99f4875e67f11b7c95e1f490cdf5f362c088e4ffaba0855 at slot 9
* call solve on the below
```
contract Solver {
    Confidential private constant confidentialContract = Confidential(0xA37CE002C8167E65540079fcf6de44b02CA93a9C);

    function _hash(bytes32 key1, bytes32 key2) private pure returns (bytes32) {
        return keccak256(abi.encodePacked(key1, key2));
    }

    function solve() external view returns (bool) {
        return confidentialContract.checkthehash(_hash(0x9371c02eefbd06113fb7e1ce6d27c3c7f6c8fc4d1b5f5f6b2620cd04d1610e3f, 0x23884ae3f28ba61fa99f4875e67f11b7c95e1f490cdf5f362c088e4ffaba0855));
    }
}
```