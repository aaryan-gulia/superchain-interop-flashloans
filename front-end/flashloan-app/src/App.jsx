import React from 'react'
import { ThirdwebProvider } from "thirdweb/react";
import { FlashLoan } from './FlashLoan';

function App() {
  
  return (
    <>
      <ThirdwebProvider>
        <FlashLoan />
      </ThirdwebProvider>
    </>
  )
}

export default App

