A DLT is a Distributed Ledger Technology. This means that rather than a single centralised ledger or database there are multiple copies distributed across many systems. There are three main types of DLT.

Permissionless – Public
These are open participation networks where anyone can join, read data, validate a transaction or take part in the consensus process. Public networks use several different high security consensus schemes including Proof-of-Work (PoW) and Proof-of-Stake (PoS).

These networks are used for globally accessible crypto currencies such as Bitcoin, Ethereum and Solana, as well as NFTs (Non-Fungible Tokens) and decentralised applications. 

Permissioned – Private
Private DLT networks are subject to permission requirements to join. Only specified individuals or nodes can join the network or read data from the ledger. They are completely owned and operated by a single organisation who sets the rules and governs the network. Transactions may be internal or may allow trusted third parties to be involved.

For example, these networks are used for totally internal processes such as a production tracking system, or a tendering system which would allow specified third parties to bid for work.

Permissioned – Consortium
Consortium DLTs are also limited access. However, they are managed cooperatively by multiple organisations, sharing governance among them. 

The use cases of this type of DLT network might include systems where collaboration is required, such as a supply chain, or a global booking system for airlines.

Advantages and Disadvantages
The following table contrasts the advantages and disadvantages of these technologies.

DLT Type	Advantages	Disadvantages
Permissionless - Public	Open to participation by anyone.

Many copies of the ledger exist, so resistant to single points of failure.

High levels of transparency.

Distributed governance of the network, resisting censorship and control. It is difficult to ban people or interfere with transactions.	All transactions are visible and traceable.

Can be slow to process transactions due to massive scale synchronisation requirements.

Very high electricity consumption for PoW.

Transactions may incur relatively high fees.


Permissioned - Private	High transaction throughput and efficiency.
Fully controlled governance of network.
Strong privacy.

    Fault tolerance risks due to centralisation.

Limited trust outside of the controlling organisation.
Permissioned - Consortium	Reasonable transaction throughput and efficiency.
Suitable for multiple organisational projects.

    Complex governance model.
Requires trust among consortium members.


What network architectures and data structure topologies can be observed across the DLTs landscape? (5%)




Task 1.2 What are the top 5 most frequently used consensus protocols in the DLT space (both permissioned and permissionless). Briefly explain the working of these protocols. (7%)

According to the Copilot (2025) and DeepSeek-R1 (2025) AI models, the current top five consensus protocols are:

Consensus Protocol	Type	Who Participates/Validates	How Agreement is Reached
Proof of Work	Permissionless	Anyone with computing power (Miners)	Solving computationally expensive hashing puzzle give right to propose a block. Dynamic difficulty to preserve chain growth time. In contention use longest chain rule. (Nakamoto, 2009) Uses a lot of energy.
Proof of Stake	Permissionless	Validators based on staked currency.	Putting the most ‘skin in the game’ allows validator to propose a block. Stake can be lost for bad behaviour. May end up with centralisation if stakes are concentrated. Energy efficient.
Practical
Byzantine Fault Tolerance	Permissioned	Trusted Nodes 	Nodes communicate in rounds to agree on the order of transactions. Requires known and trusted validators. Tolerates up to one-third of faulty or malicious nodes.
RAFT	Permissioned	Trusted Nodes	A leader node is elected to propose blocks. Followers replicate and validate the leader’s log and confirm entries. Designed for fault tolerance and fast consensus.

Proof of Authority	Permissioned	Trusted Nodes	A limited number of trusted nodes are preapproved to validate transactions. Strong authentication and trust of nodes is key. High throughput, but inherently undemocratic centralised control. 



Task 1.3 Identify three use cases of blockchain technology across different industries. Please include academic resources where possible. (8%)



1.	Supply Chain Management
2.	Decentralised Finance (DeFi)
3.	Digital Identity Verification


Sources

1.	DeepSeek-R1:8B Model via private Ollama instance. (14th Oct 2025)
2.	Microsoft Copilot, GPT-4 model (14th Oct 2025)
3.	Drescher, D. (2017) Blockchain Basics: A Non-Technical Introduction in 25 Steps. Apress.
4.	Nakamoto, S. (2009). Bitcoin: A Peer-to-Peer Electronic Cash System.
5.	Xu, J., Wang, C., & Jia, X. (2023). A Survey of Blockchain Consensus Protocols. ACM Computing Surveys, 55, 1 - 35. (https://dl.acm.org/doi/pdf/10.1145/3579845)
6.	



