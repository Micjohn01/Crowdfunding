import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const MicjohnModule = buildModule("MicjohnModule", (m) => {

    const crowdFunding = m.contract("Crowdfunding");

    return { crowdFunding };
});

export default MicjohnModule;