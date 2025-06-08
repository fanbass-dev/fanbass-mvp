import { Inter } from 'next/font/google';
import './globals.css';
import { UserContextProvider } from '../context/UserContext';
import { ToastProvider } from '../context/ToastContext';

const inter = Inter({ subsets: ['latin'] });

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <body className={inter.className}>
        <UserContextProvider>
          <ToastProvider>
            {children}
          </ToastProvider>
        </UserContextProvider>
      </body>
    </html>
  );
} 