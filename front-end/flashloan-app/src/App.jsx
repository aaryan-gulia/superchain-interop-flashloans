import { useState } from 'react'
import reactLogo from './assets/react.svg'
import viteLogo from '/vite.svg'
import './App.css'
import Typography from '@mui/material/Typography';

import Box from '@mui/material/Box';
import { ThemeProvider } from '@mui/material/styles';
import Stack from '@mui/material/Stack';
import Button from '@mui/material/Button';
import LinearProgress from '@mui/material/LinearProgress';


function App() {
  const [count, setCount] = useState(0)

  const executeFlashLoan = async () => {
  
    alert('executing flash loan!')
  }
  
  return (
    <>
      
        <Box
          sx={{
            width: 700,
            height: 500,
            borderRadius: 1,
            border: 1,
            bgcolor: 'white',
            borderColor: 'black'
          }}
        > 
          <Stack
            direction="column"
            justifyContent="center"
            alignItems="center"
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

            <Button 
              variant="contained" fullWidth 
              sx={{ 
                bgcolor: '#000'
              }}
              onClick={ executeFlashLoan }
            >
              Execute Flash Loan
            </Button>
            <Box sx={{ width: '100%' }}>
              <LinearProgress 
                variant="determinate" 
                value={50} 
              />
            </Box>
          </Stack>
        </Box>
    </>
  )
}

export default App

