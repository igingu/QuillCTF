[road-closed](https://quillctf.super.site/challenges/quillctf-challenges/road-closed)

To become an owner, one needs to be whitelisted. 

The whitelist function is not protected by any modifier, anyone can add whitelisted addresses.

I called addToWhitelist(myAddress), then changeOwner(myAddress), and then pwn(myAddress).

Then isHacked() will return true.