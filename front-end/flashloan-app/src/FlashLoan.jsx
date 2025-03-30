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
import OpLogo from './assets/op_logo.svg'
import Switch from '@mui/material/Switch';

const superchainA = import.meta.env.VITE_ENVIRONMENT == 'local' ? defineChain(
  {
    id: 901,
    name: "Supersim Chain A",
    rpc: "http://127.0.0.1:9545",
    nativeCurrency: {
      name: "Ether",
      symbol: "ETH",
      decimals: 18,
    },
  }
) :
defineChain(
    {
        id: 420120000,
        name: "interop-alpha-0",
        rpc: "https://interop-alpha-0.optimism.io",
        nativeCurrency: {
            name: "Ether",
            symbol: "ETH",
            decimals: 18,
        },
    }
)

const superchainB = import.meta.env.VITE_ENVIRONMENT == 'local' ? defineChain(
    {
        id: 902,
        name: "Supersim Chain B",
        rpc: "http://127.0.0.1:9546",
        nativeCurrency: {
            name: "Ether",
            symbol: "ETH",
            decimals: 18,
        },
    }
) :
defineChain(
    {
        id: 420120001,
        name: "interop-alpha-1",
        rpc: "https://interop-alpha-1.optimism.io",
        nativeCurrency: {
            name: "Ether",
            symbol: "ETH",
            decimals: 18,
        },
    }
)


console.log("superchainA: ", superchainA)
console.log("superchainB: ", superchainB)

export const FlashLoan = () => {
    
    const contractHandlerAddress = import.meta.env.VITE_ENVIRONMENT == 'local' ? import.meta.env.VITE_CONTRACT_HANDLER_LOCAL : import.meta.env.VITE_CONTRACT_HANDLER_DEVNET;

    const [advancedFeatures, setAdvancedFeatures] = useState(false)

    const [startCounting, setStartCounting] = useState(false)
    const [isInProgress, setIsInProgress] = useState(false)
    const [value, setValue] = useState(0)

    const [loanAmountReceived, setLoanAmountReceived] = useState({})
    const [ethSold, setEthSold] = useState({})
    const [ethBought, setEthBought] = useState({})
    const [loanAmountRepaid, setLoanAmountRepaid] = useState({})
    const [profitSent, setProfitSent] = useState({})

    const [isLoanReceived, setIsLoanReceived] = useState(false)
    const [isEthSold, setIsEthSold] = useState(false)
    const [isEthBought, setIsEthBought] = useState(false)
    const [isLoanRepaid, setIsLoanRepaid] = useState(false)
    const [isProfitSent, setIsProfitSent] = useState(false)

    const [_flashLoanId, set_flashLoanId] = useState(0)

    const switchChain = useSwitchActiveWalletChain();
    
    const chainInUse = useActiveWalletChain()

    const [currentAccount, setCurrentAccount] = useState()

    const activeAccount = useActiveAccount();
    const address = activeAccount?.address;

    useEffect(() => {
    
        setIsInProgress(false)
        setValue(0)
        setIsLoanReceived(false)
        setIsEthSold(false)
        setIsEthBought(false)
        setIsLoanRepaid(false)
        setIsProfitSent(false)

    }, [address])
    
      
    const executeFlashLoan = async () => {
        
        setValue(0);
        setIsLoanReceived(false)
        setIsEthSold(false)
        setIsEthBought(false)
        setIsLoanRepaid(false)
        setIsProfitSent(false)
        setIsInProgress(true)

        await callContract()
    }


        const [chainFrom, setChainFrom] = useState(0)
        const [chainTo, setChainTo] = useState(1)

        const handleChangeChainA = (event) => {
            console.log('chain in use: ', chainInUse)
            console.log("chain dropdown1: ", event.target.value)
            setChainFrom(event.target.value)
            setChainTo( event.target.value == 0 ? 1 : 0 )
            if( chainFrom == 0 && event.target.value == 1) {
                console.log('request change of network')
                console.log("switching to: ", superchainB)
                switchChain(superchainB)
            }
            if( chainFrom == 1 && event.target.value == 0) {
                console.log("switching to: ", superchainA)
                switchChain(superchainA)
            }
            
        };

        const handleChangeChainB = (event) => {
            console.log("chain dropdown2: ", event.target.value)
            setChainTo(event.target.value)
            setChainFrom( event.target.value == 0 ? 1 : 0 )
        };
    
    const client = createThirdwebClient({
        clientId: import.meta.env.VITE_THIRDWEB_CLIENT_ID,
      });
    

      useEffect(() => {
          console.log("useEffect loanAmountReceived called")
          console.log("prev progress: ", value)
          if( isLoanReceived && !isEthSold && !isEthBought && !isLoanRepaid && !isProfitSent) {    
              console.log("new progress: ", 20)
              setValue(20)
          }
      }, [isLoanReceived])

      useEffect(() => {
          console.log("useEffect ethSold called")
          console.log("prev progress: ", value)
          if( isEthSold && !isEthBought && !isLoanRepaid && !isProfitSent) {
              console.log("new progress: ", 40)
              setValue(40)
          }
      }, [isEthSold])

      useEffect(() => {
          console.log("useEffect ethBought called")
          console.log("prev progress: ", value)
          if( isEthBought && !isLoanRepaid && !isProfitSent){
              console.log("new progress: ", 60)
              setValue(60)
          }
      }, [isEthBought])

      useEffect(() => {
          console.log("useEffect loanAmountRepaid called")
          console.log("prev progress: ", value)
          if( isLoanRepaid && !isProfitSent) {
              console.log("new progress: ", 80)
              setValue(80)
          }
      }, [isLoanRepaid])

      useEffect(() => {
          console.log("useEffect profitSent called")
          console.log("useEffect profitSent userAddress: ", profitSent)
          console.log("prev progress: ", value)
          if(isProfitSent) {
              setValue(100)
              console.log("new progress: ", 100)
              setIsInProgress(false)
          }
      }, [isProfitSent])
      
      

    const getSigner = async (chain) => {
        return await ethers5Adapter.signer.toEthers({ client, chain: chain, account: activeAccount });
    }

    const callContract = async() => {
        const signerA = await getSigner(superchainA);
        const signerB = await getSigner(superchainB);

        console.log("contract handler address: ", contractHandlerAddress)

        const connectedContractA = new ethers.Contract(contractHandlerAddress, tokenAbi, signerA);
        const connectedContractB = new ethers.Contract(contractHandlerAddress, tokenAbi, signerB);

        
        console.log(connectedContractA)
        console.log(connectedContractB)

        setValue(0);

        if(chainInUse.id == superchainA.id) {
            try {
                await connectedContractA.initFlashLoan(superchainB.id).then(() => {
                    
                    // const address = "0x000000000000000000000000000000000000dEaD"
                    let flashLoanRecievedFilter = connectedContractA.filters.flashLoanRecieved(null,null, null, address);
                    
                    connectedContractA.on(flashLoanRecievedFilter, (flashLoanId, loanAmountRecieved, chainId, userAddress) => {
                        
                        setLoanAmountReceived({ flashLoanId: flashLoanId, amount: loanAmountRecieved, chainId: chainId, userAddress: userAddress })
                        setIsLoanReceived(true)
                        console.log('loan amount received: ', { flashLoanId: flashLoanId, amount: loanAmountRecieved, chainId: chainId, userAddress: userAddress })                            

                    })
                    
                    let soldEthFilter = connectedContractB.filters.soldEth(null, null, null, address);
                    connectedContractB.on(soldEthFilter, (flashLoanId, amount, chainId, userAddress) => {
                        setEthSold({ flashLoanId: flashLoanId, amount: amount, chainId: chainId, userAddress: userAddress })
                        setIsEthSold(true)
                        console.log('sold eth: ', { flashLoanId: flashLoanId, amount: amount, chainId: chainId, userAddress: userAddress });
                    })
                    
        
                    let boughtEthFilter = connectedContractB.filters.boughtEth(null, null, null, address);
                    connectedContractB.on(boughtEthFilter, (flashLoanId, amount, chainId, userAddress) => {
                        setEthBought({ flashLoanId: flashLoanId, amount: amount, chainId: chainId, userAddress: userAddress })
                        setIsEthBought(true)
                        console.log('bought eth: ',{ flashLoanId: flashLoanId, amount: amount, chainId: chainId, userAddress: userAddress });
                    })
        
        
                    let flashLoanRepayedFilter = connectedContractA.filters.flashLoanRepayed(null, null, null, address);
                    connectedContractA.on(flashLoanRepayedFilter, (flashLoanId, loanAmount, chainId, userAddress) => {
                        setLoanAmountRepaid({ flashLoanId: flashLoanId, amount: loanAmount, chainId: chainId, userAddress: userAddress })
                        setIsLoanRepaid(true)
                        console.log('Flash loan repaid: ', { flashLoanId: flashLoanId, amount: loanAmount, chainId: chainId, userAddress: userAddress });
                    })
        
                    let sentProfitFilter = connectedContractA.filters.sentProfit(null, null, null, address);
                    connectedContractA.on(sentProfitFilter, (flashLoanId, profit, chainId, userAddress) => {
                        setProfitSent({ flashLoanId: flashLoanId, amount: profit, chainId: chainId, userAddress: userAddress })
                        setIsProfitSent(true)
                        console.log('profit sent: ', { flashLoanId: flashLoanId, amount: profit, chainId: chainId, userAddress: userAddress });
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
                    connectedContractB.on(flashLoanRecievedFilter, (flashLoanId, loanAmountRecieved, chainId, userAddress) => {
                        setLoanAmountReceived({ flashLoanId: flashLoanId, amount: loanAmountRecieved, chainId: chainId, userAddress: userAddress })
                        setIsLoanReceived(true)
                        console.log('loan amount received: ', { flashLoanId: flashLoanId, amount: loanAmountRecieved, chainId: chainId, userAddress: userAddress });
                    }
                    )
        
                    let soldEthFilter = connectedContractA.filters.soldEth();                          
                    connectedContractA.on(soldEthFilter, (flashLoanId, amount, chainId, userAddress) => {
                        setEthSold({ flashLoanId: flashLoanId, amount: amount, chainId: chainId, userAddress: userAddress })
                        setIsEthSold(true)
                        console.log('sold eth: ', { flashLoanId: flashLoanId, amount: amount, chainId: chainId, userAddress: userAddress });
                    })
        
                    let boughtEthFilter = connectedContractA.filters.boughtEth();                          
                    connectedContractA.on(boughtEthFilter, (flashLoanId, amount, chainId, userAddress) => {
                        setEthBought({ flashLoanId: flashLoanId, amount: amount, chainId: chainId })
                        setIsEthBought(true)
                        console.log('bought eth: ',{ flashLoanId: flashLoanId, amount: amount, chainId: chainId, userAddress: userAddress });
                    })
        
        
                    let flashLoanRepayedFilter = connectedContractB.filters.flashLoanRepayed();                          
                    connectedContractB.on(flashLoanRepayedFilter, (flashLoanId, loanAmount, chainId, userAddress) => {
                        setLoanAmountRepaid({ flashLoanId: flashLoanId, amount: loanAmount, chainId: chainId })
                        setIsLoanRepaid(true)
                        console.log('value: ', value)
                        console.log('Flash loan repaid: ', { flashLoanId: flashLoanId, amount: loanAmount, chainId: chainId, userAddress: userAddress });
                    })
        
                    let sentProfitFilter = connectedContractB.filters.sentProfit();                          
                    connectedContractB.on(sentProfitFilter, (flashLoanId, profit, chainId, userAddress) => {
                        setProfitSent({ flashLoanId: flashLoanId, amount: profit, chainId: chainId })
                        setIsProfitSent(true)
                        console.log('profit sent: ', { flashLoanId: flashLoanId, amount: profit, chainId: chainId, userAddress: userAddress });
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
                    padding: "1%",
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
                    backgroundColor: '#f6f2f2'
                }}
            > 
                <Stack
                    direction="column"
                    justifyContent="center"
                    alignItems="center"
                    textAlign='center'
                    spacing={1.5}
                    padding={ "2%" }
                >
                    <Typography 
                        color="#000"
                        textTransform={ 'none' } 
                        variant="h4"
                    > 
                        Superchain Flash Loan Arbitrage  
                    </Typography>
                    <Typography 
                        color="#000"
                        textTransform={ 'none' } 
                        variant="h7"
                    > 
                        Powered by <img src={OpLogo} alt="React Logo" width={25} />
                    </Typography>

                    <Typography 
                        color="#000"
                        textTransform={ 'none' } 
                        variant="h7"
                    > 
                        Advanced features 
                        <Switch
                            checked={advancedFeatures}
                            onChange={() => setAdvancedFeatures(!advancedFeatures)}
                            name="loading"
                            color="primary"
                        />
                    </Typography>


                    {
                        (advancedFeatures) && 
                            <Box sx={{ width: 500, maxWidth: '100%' }}>
                            <TextField fullWidth type='text' label="Arbitrage contract" id="fullWidth" />
                            </Box>
                    }


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

                    {
                        (address) && (
                            <>
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
                            </>

                        )
                        
                    }
                </Stack>
            </Box>
        </>
    )
}
