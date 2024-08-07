// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

library Address {
    function isContract(address account) internal view returns (bool) {
        return account.code.length > 1;
    }

    function sendValue(address payable recepient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address has insufficient funds"
        );

        (bool success, ) = recepient.call{value: amount}("");
        require(success, "Address: unable to send value");
    }

    function functionCall(
        address target,
        bytes memory data
    ) internal returns (bytes memory) {
        return
            functionCallLogic(target, data, "Address: Low level call failed");
    }

    function functionCallLogic(
        address target,
        bytes memory data,
        string memory erroressage
    ) internal returns (bytes memory) {
        return functionCallWithValueLogic(target, data, 0, erroressage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return
            functionCallWithValueLogic(
                target,
                data,
                value,
                "Address: Low level call with value failed"
            );
    }

    function functionCallWithValueLogic(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(
            address(this).balance >= value,
            "Address: Insufficient funds for call"
        );
        require(
            isContract(target),
            "Address: call to target is not a contract"
        );

        (bool success, bytes memory returnData) = target.call{value: value}(
            data
        );
        return verifyResult(success, returnData, errorMessage);
    }

    function functionStaticCall(
        address target,
        bytes memory data
    ) internal view returns (bytes memory) {
        return
            functionStaticCallLogic(
                target,
                data,
                "Address: Low level static call failed"
            );
    }

    function functionStaticCallLogic(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(
            isContract(target),
            "Address: Target address is not a contract"
        );
        (bool success, bytes memory returnData) = target.staticcall(data);
        return verifyResult(success, returnData, errorMessage);
    }

    function functinDelegateCall(
        address target,
        bytes memory data
    ) internal returns (bytes memory) {
        return
            functinDelegateCallLogic(
                target,
                data,
                "Address: Low level delegate call failed"
            );
    }

    function functinDelegateCallLogic(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(
            isContract(target),
            "Address: Target address is not a contract"
        );
        (bool success, bytes memory returnData) = target.delegatecall(data);
        return verifyResult(success, returnData, errorMessage);
    }

    function verifyResult(
        bool success,
        bytes memory returnData,
        string memory errormessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returnData;
        } else {
            if (returnData.length > 0) {
                assembly {
                    let returnDatasize := mload(returnData)
                    revert(add(32, returnData), returnDatasize)
                }
            } else {
                revert(errormessage);
            }
        }
    }
}
