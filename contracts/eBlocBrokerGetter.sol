// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;
pragma experimental ABIEncoderV2;

import "./eBlocBroker.sol";
import "./Lib.sol";

contract eBlocBrokerGetter {
    address eBlocBrokerAddress;
    constructor(address _eBlocBrokerAddress) {
        eBlocBrokerAddress = _eBlocBrokerAddress;
    }

    function getProviderInfo(address provider, uint arg) public view returns (uint) {
        uint32 val1;
        Lib.ProviderInfo memory val2;
        (val1, val2) = eBlocBroker(eBlocBrokerAddress).getProviderInfo(provider, 0);
        if (arg == 0)
            return val2.availableCore;
        if (arg == 1)
            return val2.commitmentBlockDur;
        if (arg == 2)
            return val2.priceCoreMin;
        if (arg == 3)
            return val2.priceDataTransfer;
        if (arg == 4)
            return val2.priceStorage;
        if (arg == 5)
            return val2.priceCache;
    }
}
