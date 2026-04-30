import { Habit } from '@/types/habit';
import HabitCard from './HabitCard';

interface HabitListProps {
  habits: Habit[];
  onEdit: (habit: Habit) => void;
  onDelete: (id: string) => void;
  onToggle: (updated: Habit) => void;
}

export default function HabitList({ habits, onEdit, onDelete, onToggle }: HabitListProps) {
  return (
    <div>
      {habits.map((habit) => (
        <HabitCard key={habit.id} habit={habit}
          onEdit={() => onEdit(habit)}
          onDelete={() => onDelete(habit.id)}
          onToggle={onToggle}
        />
      ))}
    </div>
  );
}