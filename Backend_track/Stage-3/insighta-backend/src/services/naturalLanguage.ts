export function parseNaturalQuery(query: string) {
  const q = query.toLowerCase().trim();
  const filters: any = {};

  // Age group keywords
  if (/\bchild\b/.test(q)) filters.age_group = 'child';
  else if (/\bteenager\b|\bteen\b/.test(q)) filters.age_group = 'teenager';
  else if (/\badult\b/.test(q)) filters.age_group = 'adult';
  else if (/\bsenior\b/.test(q)) filters.age_group = 'senior';

  // "young" implies age range 16-24
  if (/\byoung\b/.test(q)) {
    filters.min_age = 16;
    filters.max_age = 24;
  }

  // Gender
  if (/\bmale\b/.test(q) && !/\bfemale\b/.test(q)) filters.gender = 'male';
  else if (/\bfemale\b/.test(q) && !/\bmale\b/.test(q)) filters.gender = 'female';
  // if both male and female appear, ignore gender filter

  // Age numbers "above 30", "below 18", "above 17", etc.
  const aboveMatch = q.match(/above\s*(\d+)/);
  if (aboveMatch) filters.min_age = parseInt(aboveMatch[1]) + 1; // "above 30" means >=31? Typically "above 30" means >30, so min_age = 31. We'll do >.
  const belowMatch = q.match(/below\s*(\d+)/);
  if (belowMatch) filters.max_age = parseInt(belowMatch[1]) - 1; // below 18 -> <=17
  
  // Country mentions
  const countryMap: Record<string, string> = {
    nigeria: 'NG', angola: 'AO', kenya: 'KE', 'united states': 'US', 'us': 'US',
    benin: 'BJ', 'south africa': 'ZA',
  };
  for (const [name, code] of Object.entries(countryMap)) {
    if (q.includes(name)) {
      filters.country_id = code;
      break;
    }
  }

  // Additional mappings as per spec
  // "young males from nigeria" -> gender=male, min_age=16, max_age=24, country_id=NG
  // "females above 30" -> gender=female, min_age=31
  // "adult males from kenya" -> gender=male, age_group=adult, country_id=KE

  if (Object.keys(filters).length === 0) {
    throw new Error('Unable to interpret query');
  }
  return filters;
}