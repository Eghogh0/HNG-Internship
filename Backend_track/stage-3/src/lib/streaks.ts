export function calculateCurrentStreak(completions: string[], today?: string): number {
  if (!completions || completions.length === 0) return 0;
  const unique = Array.from(new Set(completions));
  unique.sort((a, b) => b.localeCompare(a));
  const todayDate = today || new Date().toISOString().slice(0, 10);
  if (!unique.includes(todayDate)) return 0;
  let streak = 1;
  let current = new Date(todayDate);
  for (let i = 1; i < unique.length; i++) {
    const prev = new Date(current);
    prev.setDate(prev.getDate() - 1);
    const prevStr = prev.toISOString().slice(0, 10);
    if (unique.includes(prevStr)) {
      streak++;
      current = prev;
    } else {
      break;
    }
  }
  return streak;
}