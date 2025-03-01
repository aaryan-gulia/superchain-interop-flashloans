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
import { useActiveAccount, useActiveWalletConnectionStatus, useActiveWalletChain } from "thirdweb/react";
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
    id: 901,
    name: "Supersim L2 Chain A",
    rpc: "http://127.0.0.1:9545",
    nativeCurrency: {
      name: "Ether",
      symbol: "ETH",
      decimals: 18,
    },
  }
)
const superchainB = defineChain(
  {
    id: 902,
    name: "Supersim L2 Chain B",
    rpc: "http://127.0.0.1:9546",
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

    const { value, reset } = useCountUp({
        isCounting: startCounting,
        duration: 7,
        easing: 'linear',
        start: 0,
        end: 100,
        onComplete: () => {

            setIsInProgress(false)

            return ({
                shouldRepeat: false,
                delay: 1,
            })
        }
      })
      

    const executeFlashLoan = async () => {
        console.log('activating counting')
        reset();
        setStartCounting(true)
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
            console.log("chain dropdown1: ", event.target.value)
            setChainFrom(event.target.value)
            setChainTo( event.target.value == 0 ? 1 : 0 )
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
    
    const client = createThirdwebClient({
        clientId: import.meta.env.VITE_THIRDWEB_CLIENT_ID,
      });

    const getSigner = async () => {
        return await ethers5Adapter.signer.toEthers({ client, chain: superchainA, account: activeAccount });
    }

    const callContract = async() => {
        const signer = await getSigner();
        const connectedContract = new ethers.Contract("0xaa8DE454aD9231FB41A74283D8dA42C5A321C534", tokenAbi, signer);

        console.log(connectedContract)
        await connectedContract.initFlashLoan(902);

        console.log('contract called')
    }

    
    return (
        <>
            <ConnectButton theme="light" client={client} chains={ [ superchainA, superchainB] } />

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
                                >
                                    <MenuItem value={0}>Chain A</MenuItem>
                                    <MenuItem value={1}>Chain B</MenuItem>
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
                                >
                                    <MenuItem value={0}>Chain A</MenuItem>
                                    <MenuItem value={1}>Chain B</MenuItem>
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
                    disabled={ isInProgress }
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
                        value > 100/6*1 &&
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
                        value > 100/6*2 && 
                        <Stack 
                            direction="row"
                            spacing={2}
                            fullWidth
                        >
                            <Typography variant="h5" sx={{ color: 'green' }} >
                                <CheckCircleIcon textColor='green' />
                            </Typography>
                            <Typography variant="h7" >
                                Borrowing ETH on {chains[chainFrom].chainName}
                            </Typography>
                        </Stack>
                    }
                    {
                        value > 100/6*3 &&
                        <Stack 
                            direction="row"
                            spacing={2}
                            fullWidth
                        >
                            <Typography variant="h5" sx={{ color: 'green' }} >
                                <CheckCircleIcon textColor='green' />
                            </Typography>
                            <Typography variant="h7" >
                                Selling ETH for USDC on {chains[chainTo].chainName}
                            </Typography>
                        </Stack>
                    }
                    {
                        value > 100/6*4 &&
                        <Stack 
                            direction="row"
                            spacing={2}
                            fullWidth
                        >
                            <Typography variant="h5" sx={{ color: 'green' }} >
                                <CheckCircleIcon textColor='green' />
                            </Typography>
                            <Typography variant="h7" >
                                Buying ETH on {chains[chainTo].chainName}
                            </Typography>
                        </Stack>
                    }
                    {
                        value > 100/6*5 &&
                        <Stack 
                            direction="row"
                            spacing={2}
                            fullWidth
                        >
                            <Typography variant="h5" sx={{ color: 'green' }} >
                                <CheckCircleIcon textColor='green' />
                            </Typography>
                            <Typography variant="h7" >
                                Repaying flash loan on {chains[chainFrom].chainName}
                            </Typography>
                        </Stack>
                    }
                    {
                        value > 99 &&
                        <Stack 
                            direction="row"
                            spacing={2}
                            fullWidth
                        >
                            <Typography variant="h5" sx={{ color: 'green' }} >
                                <CheckCircleIcon textColor='green' />
                            </Typography>
                            <Typography variant="h7" >
                                Review your profit on your wallet account
                            </Typography>
                        </Stack>
                    }
                    </Stack>
                </Stack>
            </Box>
        </>
    )
}
