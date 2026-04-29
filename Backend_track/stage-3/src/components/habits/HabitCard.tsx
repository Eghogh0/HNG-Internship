'use client';
import { Habit } from '@/types/habit';
import { getHabitSlug } from '@/lib/slug';
import { calculateCurrentStreak } from '@/lib/streaks';
import { toggleHabitCompletion } from '@/lib/habits';

interface HabitCardProps {
  habit: Habit;
  onEdit: () => void;
  onDelete: () => void;
  onToggle: (updated: Habit) => void;
}

export default function HabitCard({ habit, onEdit, onDelete, onToggle }: HabitCardProps) {
  const slug = getHabitSlug(habit.name);
  const today = new Date().toISOString().slice(0, 10);
  const isCompleted = habit.completions.includes(today);
  const streak = calculateCurrentStreak(habit.completions);

  const handleToggle = () => {
    onToggle(toggleHabitCompletion(habit, today));
  };

  const confirmDelete = () => {
    if (window.confirm('Are you sure?')) onDelete();
  };

  return (
    <div
      data-testid={`habit-card-${slug}`}
      className={`mb-2 rounded p-4 shadow ${isCompleted ? 'bg-green-100' : 'bg-white'}`}
    >
      <div className="flex items-center justify-between">
        <div>
          <h3 className="font-bold">{habit.name}</h3>
          {habit.description && <p className="text-sm text-gray-600">{habit.description}</p>}
          <p data-testid={`habit-streak-${slug}`} className="text-sm">Streak: {streak}</p>
        </div>
        <div className="flex gap-2">
          <button onClick={handleToggle} data-testid={`habit-complete-${slug}`}
            className={`rounded px-3 py-1 text-white ${isCompleted ? 'bg-yellow-500' : 'bg-green-500'}`}>
            {isCompleted ? 'Unmark' : 'Complete'}
          </button>
          <button onClick={onEdit} data-testid={`habit-edit-${slug}`}
            className="rounded bg-blue-500 px-3 py-1 text-white">Edit</button>
          <button onClick={confirmDelete} data-testid={`habit-delete-${slug}`}
            className="rounded bg-red-500 px-3 py-1 text-white">Delete</button>
        </div>
      </div>
    </div>
  );
}