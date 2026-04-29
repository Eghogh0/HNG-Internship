'use client';
import { useState } from 'react';
import { Habit } from '@/types/habit';
import { validateHabitName } from '@/lib/validators';
import { getSession } from '@/lib/auth';

interface HabitFormProps {
  habit?: Habit | null;
  onSave: (habit: Habit) => void;
  onCancel: () => void;
}

export default function HabitForm({ habit, onSave, onCancel }: HabitFormProps) {
  const [name, setName] = useState(habit?.name || '');
  const [description, setDescription] = useState(habit?.description || '');
  const [error, setError] = useState('');

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    const validation = validateHabitName(name);
    if (!validation.valid) {
      setError(validation.error || '');
      return;
    }
    const session = getSession();
    if (!session) return;
    const newHabit: Habit = habit
      ? { ...habit, name: validation.value, description }
      : {
          id: Date.now().toString(36) + Math.random().toString(36).substr(2, 9),
          userId: session.userId,
          name: validation.value,
          description,
          frequency: 'daily',
          createdAt: new Date().toISOString(),
          completions: [],
        };
    onSave(newHabit);
  };

  return (
    <form data-testid="habit-form" onSubmit={handleSubmit} className="mb-4 rounded bg-white p-4 shadow">
      {error && <p className="text-red-500">{error}</p>}
      <div className="mb-2">
        <label htmlFor="habit-name" className="block text-sm font-medium">Name</label>
        <input id="habit-name" data-testid="habit-name-input" type="text" value={name}
          onChange={(e) => setName(e.target.value)} className="w-full rounded border p-2" />
      </div>
      <div className="mb-2">
        <label htmlFor="habit-description" className="block text-sm font-medium">Description</label>
        <input id="habit-description" data-testid="habit-description-input" type="text" value={description}
          onChange={(e) => setDescription(e.target.value)} className="w-full rounded border p-2" />
      </div>
      <div className="mb-2">
        <label htmlFor="habit-frequency" className="block text-sm font-medium">Frequency</label>
        <select id="habit-frequency" data-testid="habit-frequency-select" value="daily" disabled className="w-full rounded border p-2 bg-gray-100">
          <option value="daily">Daily</option>
        </select>
      </div>
      <div className="flex gap-2">
        <button type="submit" data-testid="habit-save-button" className="rounded bg-blue-600 px-4 py-2 text-white">
          {habit ? 'Update' : 'Save'}
        </button>
        <button type="button" onClick={onCancel} className="rounded bg-gray-300 px-4 py-2">Cancel</button>
      </div>
    </form>
  );
}