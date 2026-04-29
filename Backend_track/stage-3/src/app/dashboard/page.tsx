'use client';
import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import ProtectedRoute from '@/components/shared/ProtectedRoute';
import HabitList from '@/components/habits/HabitList';
import HabitForm from '@/components/habits/HabitForm';
import { getSession, logout } from '@/lib/auth';
import type { Habit } from '@/types/habit';
import { STORAGE_KEYS } from '@/lib/constants';

function DashboardContent() {
  const router = useRouter();
  const [habits, setHabits] = useState<Habit[]>([]);
  const [showForm, setShowForm] = useState(false);
  const [editingHabit, setEditingHabit] = useState<Habit | null>(null);

  const session = getSession();
  const userId = session?.userId;

  const loadHabits = () => {
    const stored = localStorage.getItem(STORAGE_KEYS.HABITS);
    const allHabits: Habit[] = stored ? JSON.parse(stored) : [];
    setHabits(allHabits.filter(h => h.userId === userId));
  };

  useEffect(() => {
    loadHabits();
  }, []);

  const handleSave = (habit: Habit) => {
    const stored = localStorage.getItem(STORAGE_KEYS.HABITS);
    const allHabits: Habit[] = stored ? JSON.parse(stored) : [];
    if (editingHabit) {
      const idx = allHabits.findIndex(h => h.id === habit.id);
      if (idx !== -1) allHabits[idx] = habit;
    } else {
      allHabits.push(habit);
    }
    localStorage.setItem(STORAGE_KEYS.HABITS, JSON.stringify(allHabits));
    setEditingHabit(null);
    setShowForm(false);
    loadHabits();
  };

  const handleDelete = (id: string) => {
    const stored = localStorage.getItem(STORAGE_KEYS.HABITS);
    const allHabits: Habit[] = stored ? JSON.parse(stored) : [];
    localStorage.setItem(STORAGE_KEYS.HABITS, JSON.stringify(allHabits.filter(h => h.id !== id)));
    loadHabits();
  };

  const handleToggle = (updated: Habit) => {
    const stored = localStorage.getItem(STORAGE_KEYS.HABITS);
    const allHabits: Habit[] = stored ? JSON.parse(stored) : [];
    const idx = allHabits.findIndex(h => h.id === updated.id);
    if (idx !== -1) allHabits[idx] = updated;
    localStorage.setItem(STORAGE_KEYS.HABITS, JSON.stringify(allHabits));
    loadHabits();
  };

  const handleLogout = () => {
    logout();
    router.push('/login');
  };

  return (
    <div data-testid="dashboard-page" className="min-h-screen bg-gray-50 p-4">
      <header className="mb-6 flex items-center justify-between">
        <h1 className="text-2xl font-bold">Dashboard</h1>
        <button onClick={handleLogout} data-testid="auth-logout-button" className="rounded bg-red-500 px-4 py-2 text-white">Logout</button>
      </header>

      {!showForm && !editingHabit && (
        <button onClick={() => setShowForm(true)} data-testid="create-habit-button" className="mb-4 rounded bg-blue-600 px-4 py-2 text-white">Create Habit</button>
      )}

      {(showForm || editingHabit) && (
        <HabitForm
          habit={editingHabit}
          onSave={handleSave}
          onCancel={() => { setShowForm(false); setEditingHabit(null); }}
        />
      )}

      {habits.length === 0 && !showForm && (
        <p data-testid="empty-state" className="text-gray-500">No habits yet. Create one to get started!</p>
      )}

      <HabitList
        habits={habits}
        onEdit={(habit) => { setEditingHabit(habit); setShowForm(false); }}
        onDelete={handleDelete}
        onToggle={handleToggle}
      />
    </div>
  );
}

export default function DashboardPage() {
  return <ProtectedRoute><DashboardContent /></ProtectedRoute>;
}