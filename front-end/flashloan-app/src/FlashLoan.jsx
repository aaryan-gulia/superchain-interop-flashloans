import React, { useEffect } from 'react'
import { useState } from 'react'
import reactLogo from './assets/react.svg'
import viteLogo from '/vite.svg'
import './App.css'
import Typography from '@mui/material/Typography';
import { ConnectButton, darkTheme, lightTheme } from "thirdweb/react";
import Box from '@mui/material/Box';
import { ThemeProvider } from '@mui/material/styles';
import Stack from '@mui/material/Stack';
import Button from '@mui/material/Button';
// import LinearProgress from '@mui/material/LinearProgress';
import LinearProgress from '@mui/joy/LinearProgress';
import { defineChain, optimismSepolia } from "thirdweb/chains";
import { createThirdwebClient } from "thirdweb";
import { ethers5Adapter } from "thirdweb/adapters/ethers5";
import { ethers } from 'ethers';
import { abi as tokenAbi} from './assets/tokenAbi.json';
import { useCountUp } from 'use-count-up';
import InputLabel from '@mui/material/InputLabel';
import TextField from '@mui/material/TextField';
import CheckCircleIcon from '@mui/icons-material/CheckCircle';
import Select from '@mui/material/Select';
import MenuItem from '@mui/material/MenuItem';
import FormControl from '@mui/material/FormControl';
import CircularProgress from '@mui/material/CircularProgress';
import { useActiveAccount, useActiveWalletConnectionStatus, useActiveWalletChain, useSwitchActiveWalletChain } from "thirdweb/react";

// import { createPublicClient, http, defineChain } from 'viem'
// import { mainnet } from 'viem/chains'
 
// 2. Set up your client with desired chain & transport.
// const client = createPublicClient({
//   chain: mainnet,
//   transport: http(),
// })

// export const superChainA = defineChain({
//     id: 901,
//     name: 'Supersim L2 Chain A',
//     nativeCurrency: {
//       decimals: 18,
//       name: 'Ether',
//       symbol: 'ETH',
//     },
//     rpcUrls: {
//       default: {
//         http: ['http://127.0.0.1:9545'],
//       },
//     },
//     blockExplorers: {
//       default: { name: 'Explorer', url: 'https://explorer.zora.energy' },
//     },
//   })

const superchainA = defineChain(
  {
    id: 420120000,
    name: "interop-alpha-0",
    //rpc: "http://127.0.0.1:9545",
    rpc: 'https://interop-alpha-0.optimism.io',
    nativeCurrency: {
      name: "Ether",
      symbol: "ETH",
      decimals: 18,
    },
  }
)
const superchainB = defineChain(
  {
    id: 420120001,
    name: "interop-alpha-1",
    // rpc: "http://127.0.0.1:9546",
    rpc: 'https://interop-alpha-1.optimism.io',
    nativeCurrency: {
      name: "Ether",
      symbol: "ETH",
      decimals: 18,
    },
  }
)

export const FlashLoan = () => {

    const [startCounting, setStartCounting] = useState(false)
    const [isInProgress, setIsInProgress] = useState(false)
    const [value, setValue] = useState(0)

    const [loanAmountReceived, setLoanAmountReceived] = useState({})
    const [ethSold, setEthSold] = useState({})
    const [ethBought, setEthBought] = useState({})
    const [loanAmountRepaid, setLoanAmountRepaid] = useState({})
    const [profitSent, setProfitSent] = useState({})

    const switchChain = useSwitchActiveWalletChain();
    
    const chainInUse = useActiveWalletChain()
    
    // const { value, reset } = useCountUp({
    //     isCounting: startCounting,
    //     duration: 7,
    //     easing: 'linear',
    //     start: 0,
    //     end: 100,
    //     onComplete: () => {

    //         setIsInProgress(false)

    //         return ({
    //             shouldRepeat: false,
    //             delay: 1,
    //         })
    //     }
    //   })
      

    const executeFlashLoan = async () => {
        console.log('activating counting')
        // reset();
        setValue(0);
        // setStartCounting(true)
        setIsInProgress(true)

        await callContract()
    }


        const [chainFrom, setChainFrom] = useState(0)
        const [chainTo, setChainTo] = useState(1)

        const chains = [
            {
                chainName: "Chain A"
            },
            {
                chainName: "Chain B"
            }
        ]

        const handleChangeChainA = (event) => {
            console.log('chain in use: ', chainInUse)
            console.log("chain dropdown1: ", event.target.value)
            setChainFrom(event.target.value)
            setChainTo( event.target.value == 0 ? 1 : 0 )
            if( chainFrom == 0 && event.target.value == 1) {
                console.log('request change of network')
                switchChain(superchainB)
            }
            if( chainFrom == 1 && event.target.value == 0) {
                switchChain(superchainA)
            }
            
        };

        const handleChangeChainB = (event) => {
            console.log("chain dropdown2: ", event.target.value)
            setChainTo(event.target.value)
            setChainFrom( event.target.value == 0 ? 1 : 0 )
        };
    

    const [progressPercent, setProgressPercent] = useState(37)

        // we need an amount input

        // Initiating Flash Loan
        // Borrowing X ETH
        // Selling X ETH for Y USDC
        // Buying Z ETH
        // Repaying Flash loan
        // End of flash loan
        // Review your profit in your wallet accoun


    const activeAccount = useActiveAccount();
    console.log('activeAccount: ', activeAccount)
    
    const client = createThirdwebClient({
        clientId: import.meta.env.VITE_THIRDWEB_CLIENT_ID,
      });

      useEffect(() => {
      
        return () => {
          let counter = 0;
          counter += loanAmountReceived.chainId > 0 ? 1 : 0;
          counter += loanAmountRepaid.chainId > 0 ? 1 : 0;
          counter += ethSold.chainId > 0 ? 1 : 0;
          counter += ethBought.chainId > 0 ? 1 : 0;
          counter += profitSent.chainId > 0 ? 1 : 0;
          console.log('counter: ', counter)
          
          if(counter == 5 || parseInt(profitSent.chainId) > 0 ) {
            setValue(100);
            setIsInProgress(false);
          } else {
            setValue(20*counter)
          }
        }
      }, [loanAmountReceived, loanAmountRepaid, ethSold, ethBought, profitSent])
      

    const getSigner = async (chain) => {
        return await ethers5Adapter.signer.toEthers({ client, chain: chain, account: activeAccount });
    }

    const callContract = async() => {
        const signerA = await getSigner(superchainA);
        const signerB = await getSigner(superchainB);

        const connectedContractA = new ethers.Contract(import.meta.env.VITE_CONTRACT_HANDLER, tokenAbi, signerA);
        const connectedContractB = new ethers.Contract(import.meta.env.VITE_CONTRACT_HANDLER, tokenAbi, signerB);

        
        console.log(connectedContractA)
        console.log(connectedContractB)

        setValue(0);

        if(chainInUse.id == 420120000) {
            try {
                await connectedContractA.initFlashLoan(superchainB.id).then(() => {
        
                    let flashLoanRecievedFilter = connectedContractA.filters.flashLoanRecieved();                          
                    connectedContractA.on(flashLoanRecievedFilter, (loanAmountRecieved, chainId) => {
                        setLoanAmountReceived({ amount: loanAmountRecieved, chainId: chainId })
                        // if(value <= 10) {
                        //     setValue(20);
                        // }
                        console.log('loan amount received: ', { amount: loanAmountRecieved, chainId: chainId });
                    }
                    )
        
                    let soldEthFilter = connectedContractB.filters.soldEth();                          
                    connectedContractB.on(soldEthFilter, (amount, chainId) => {
                        setEthSold({ amount: amount, chainId: chainId })
                        // if(value <= 40) {
                        //     setValue(40);
                        // }
                        console.log('sold eth: ', { amount: amount, chainId: chainId });
                    })
        
                    let boughtEthFilter = connectedContractB.filters.boughtEth();                          
                    connectedContractB.on(boughtEthFilter, (amount, chainId) => {
                        setEthBought({ amount: amount, chainId: chainId })
                        // if(value <= 60) {
                        //     setValue(60);
                        // }
                        console.log('bought eth: ',{ amount: amount, chainId: chainId });
                    })
        
        
                    let flashLoanRepayedFilter = connectedContractA.filters.flashLoanRepayed();                          
                    connectedContractA.on(flashLoanRepayedFilter, (loanAmount, chainId) => {
                        setLoanAmountRepaid({ amount: loanAmount, chainId: chainId })
                        // if(value<=80) {
                        //     setValue(80);
                        // }
                        console.log('Flash loan repaid: ', { amount: loanAmount, chainId: chainId });
                    })
        
                    let sentProfitFilter = connectedContractA.filters.sentProfit();                          
                    connectedContractA.on(sentProfitFilter, (profit, chainId) => {
                        setProfitSent({ amount: profit, chainId: chainId })
                        // setValue(100);
                        // setIsInProgress(false);
                        console.log('profit sent: ', { amount: profit, chainId: chainId });
                    })
                });
            } catch (error) {
                alert(error.message)
                setValue(0);
                setIsInProgress(false);
            }

        } else {
            try {
                await connectedContractB.initFlashLoan(superchainA.id).then(() => {
        
                    let flashLoanRecievedFilter = connectedContractB.filters.flashLoanRecieved();                          
                    connectedContractB.on(flashLoanRecievedFilter, (loanAmountRecieved, chainId) => {
                        setLoanAmountReceived({ amount: loanAmountRecieved, chainId: chainId })
                        // if(value <= 10) {
                        //     setValue(20);
                        // }
                        console.log('loan amount received: ', { amount: loanAmountRecieved, chainId: chainId });
                    }
                    )
        
                    let soldEthFilter = connectedContractA.filters.soldEth();                          
                    connectedContractA.on(soldEthFilter, (amount, chainId) => {
                        setEthSold({ amount: amount, chainId: chainId })
                        // if(value <= 40) {
                        //     setValue(40);
                        // }
                        console.log('sold eth: ', { amount: amount, chainId: chainId });
                    })
        
                    let boughtEthFilter = connectedContractA.filters.boughtEth();                          
                    connectedContractA.on(boughtEthFilter, (amount, chainId) => {
                        setEthBought({ amount: amount, chainId: chainId })
                        // if(value <= 60) {
                        //     setValue(60);
                        // }
                        console.log('bought eth: ',{ amount: amount, chainId: chainId });
                    })
        
        
                    let flashLoanRepayedFilter = connectedContractB.filters.flashLoanRepayed();                          
                    connectedContractB.on(flashLoanRepayedFilter, (loanAmount, chainId) => {
                        setLoanAmountRepaid({ amount: loanAmount, chainId: chainId })
                        console.log('value: ', value)
                        // if(value<=80) {
                        //     setValue(80);
                        // }
                        console.log('Flash loan repaid: ', { amount: loanAmount, chainId: chainId });
                    })
        
                    let sentProfitFilter = connectedContractB.filters.sentProfit();                          
                    connectedContractB.on(sentProfitFilter, (profit, chainId) => {
                        setProfitSent({ amount: profit, chainId: chainId })
                        // setValue(100);
                        // setIsInProgress(false);
                        console.log('profit sent: ', { amount: profit, chainId: chainId });
                    })
                });
            } catch (error) {
                alert(error.message)
                setValue(0);
                setIsInProgress(false);
            }

        }

        console.log('contract called')
    }

    
    return (
        <>
            <Box
                sx={{
                    justifyContent: "right",
                    alignItems: "right",
                    textAlign: 'right',
                    spacing: 2,
                    padding: "1%"
                }}
            >
                <ConnectButton theme="light" client={client} chains={ [ superchainA, superchainB] } />
            </Box>

            <Box
                color="#000"
                sx={{
                    width: 700,
                    height: 550,
                    borderRadius: 1,
                    border: 1,
                    borderColor: 'black',
                }}
            > 
                <Stack
                    direction="column"
                    justifyContent="center"
                    alignItems="center"
                    textAlign='center'
                    spacing={2}
                    padding={ "5%" }
                >
                    <Typography 
                    color="#000"
                    textTransform={ 'none' } 
                    variant="h4"
                    > 
                    Superchain Flash Loan Arbitrage  
                    </Typography>

                    {/* <Box sx={{ width: 500, maxWidth: '100%' }}>
                      <TextField fullWidth type='number' label="Amount (ETH)" id="fullWidth" />
                    </Box> */}

                    <Stack 
                        direction="row"
                        justifyContent="center"
                        alignItems="center"
                        textAlign='center'
                        spacing={2}
                        fullWidth
                    >
                        <Box sx={{ minWidth: 120 }}>
                            <FormControl fullWidth>
                                <InputLabel id="demo-simple-select-label">From</InputLabel>
                                <Select
                                    labelId="demo-simple-select-label"
                                    id="demo-simple-select"
                                    value={ chainFrom }
                                    label="From"
                                    onChange={handleChangeChainA}
                                    disabled={ isInProgress || !activeAccount }
                                >
                                    <MenuItem value={0}>Devnet 0</MenuItem>
                                    <MenuItem value={1}>Devnet 1</MenuItem>
                                </Select>
                            </FormControl>
                        </Box>
                        <Box sx={{ minWidth: 120 }}>
                            <FormControl fullWidth>
                                <InputLabel id="demo-simple-select-label-chainB">To</InputLabel>
                                <Select
                                    labelId="demo-simple-select-label-chainB"
                                    id="demo-simple-select-chainB"
                                    value={ chainTo }
                                    label="From"
                                    onChange={handleChangeChainB}
                                    disabled
                                >
                                    <MenuItem value={0}>Devnet 0</MenuItem>
                                    <MenuItem value={1}>Devnet 1</MenuItem>
                                </Select>
                            </FormControl>
                        </Box>

                    </Stack>


                    <Button 
                    variant="contained" fullWidth 
                    sx={{ 
                        bgcolor: '#000'
                    }}
                    // onClick={ callContract }
                    onClick={ executeFlashLoan }
                    disabled={ isInProgress || !activeAccount }
                    >

                    { 
                        !isInProgress ? 
                        (
                            'Execute Flash Loan '
                        ) :
                        (
                            <CircularProgress color="inherit" />
                        )
                    }
                    
                    </Button>
                    <Box sx={{ width: '100%' }}>
                        <LinearProgress
                            determinate
                            variant="solid"
                            size="sm"
                            thickness={24}
                            value={Number(value)}
                            sx={{
                                backgroundColor: '#fdd6cd',
                                color: '#f53306',
                                textColor: 'white',
                                '--LinearProgress-radius': '20px',
                                '--LinearProgress-thickness': '24px',
                            }}
                        >
                            <Typography
                                level="body-xs"
                                textColor="common.white"
                                sx={{ fontWeight: 'xl', mixBlendMode: 'difference' }}
                            >
                                {`${Math.round(Number(value))}%`}
                            </Typography>
                        </LinearProgress>
                    </Box>
                    
                    <Stack 
                        direction="column"
                        justifyContent="left"
                        alignItems="left"
                        textAlign='left'
                        spacing={2}
                        fullWidth
                    >
                    
                    {
                        value >= 10 &&
                            <Stack 
                                direction="row"
                                spacing={2}
                                width={600}
                            >
                                <Typography variant="h5" sx={{ color: 'green' }} >
                                    <CheckCircleIcon textColor='green' />
                                </Typography>
                                <Typography variant="h7" >
                                    Initiating flash loan
                                </Typography>
                            </Stack>
                    }
                    {
                        value >= 100/5*1 && 
                        <Stack 
                            direction="row"
                            spacing={2}
                            fullWidth
                        >
                            <Typography variant="h5" sx={{ color: 'green' }} >
                                <CheckCircleIcon textColor='green' />
                            </Typography>
                            <Typography variant="h7" >
                                Borrowing { parseInt(loanAmountReceived.amount)/1000000000000000000} ETH on Chain { parseInt(loanAmountReceived.chainId) }
                            </Typography>
                        </Stack>
                    }
                    {
                        value >= 100/5*2 &&
                        <Stack 
                            direction="row"
                            spacing={2}
                            fullWidth
                        >
                            <Typography variant="h5" sx={{ color: 'green' }} >
                                <CheckCircleIcon textColor='green' />
                            </Typography>
                            <Typography variant="h7" >
                                Selling { parseInt(ethSold.amount)/1000000000000000000 } ETH for USDC on { parseInt(ethSold.chainId) }
                            </Typography>
                        </Stack>
                    }
                    {
                        value >= 100/5*3 &&
                        <Stack 
                            direction="row"
                            spacing={2}
                            fullWidth
                        >
                            <Typography variant="h5" sx={{ color: 'green' }} >
                                <CheckCircleIcon textColor='green' />
                            </Typography>
                            <Typography variant="h7" >
                                Buying { parseInt(ethBought.amount)/1000000000000000000 } ETH on { parseInt(ethBought.chainId) }
                            </Typography>
                        </Stack>
                    }
                    {
                        value >= 100/5*4 &&
                        <Stack 
                            direction="row"
                            spacing={2}
                            fullWidth
                        >
                            <Typography variant="h5" sx={{ color: 'green' }} >
                                <CheckCircleIcon textColor='green' />
                            </Typography>
                            <Typography variant="h7" >
                                Repaying flash loan of { parseInt(loanAmountRepaid.amount)/1000000000000000000 } on Chain { parseInt(loanAmountRepaid.chainId) }
                            </Typography>
                        </Stack>
                    }
                    {
                        value == 100 &&
                        <Stack 
                            direction="row"
                            spacing={2}
                            fullWidth
                        >
                            <Typography variant="h5" sx={{ color: 'green' }} >
                                <CheckCircleIcon textColor='green' />
                            </Typography>
                            <Typography variant="h7" >
                                Review your profit of { parseInt(profitSent.amount)/1000000000000000000 } ETH on your wallet account
                            </Typography>
                        </Stack>
                    }
                    </Stack>
                </Stack>
            </Box>
        </>
    )
}
