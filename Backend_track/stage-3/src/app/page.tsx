'use client';
import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import SplashScreen from '@/components/shared/SplashScreen';
import { getSession } from '@/lib/auth';

export default function HomePage() {
  const router = useRouter();
  const [showSplash, setShowSplash] = useState(true);

  useEffect(() => {
    const timer = setTimeout(() => {
      const session = getSession();
      if (session) {
        router.push('/dashboard');
      } else {
        router.push('/login');
      }
      setShowSplash(false);
    }, 1500);
    return () => clearTimeout(timer);
  }, [router]);

  if (showSplash) return <SplashScreen />;
  return null;
}