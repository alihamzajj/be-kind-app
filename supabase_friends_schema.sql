-- ==============================================================================
-- BE KIND: FRIENDS & SOCIAL SYSTEM (SUPABASE)
-- ==============================================================================

-- 1. FRIENDSHIPS TABLE
CREATE TABLE IF NOT EXISTS public.friendships (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  friend_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  status TEXT NOT NULL DEFAULT 'accepted', -- 'pending', 'accepted'
  created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL,
  CONSTRAINT unique_friendship UNIQUE (user_id, friend_id)
);

ALTER TABLE public.friendships ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users can view their friendships." ON public.friendships;
DROP POLICY IF EXISTS "Users can insert friendships." ON public.friendships;
DROP POLICY IF EXISTS "Users can delete friendships." ON public.friendships;

CREATE POLICY "Users can view their friendships."
  ON public.friendships FOR SELECT
  USING (auth.uid() = user_id OR auth.uid() = friend_id);

CREATE POLICY "Users can insert friendships."
  ON public.friendships FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete friendships."
  ON public.friendships FOR DELETE
  USING (auth.uid() = user_id OR auth.uid() = friend_id);

-- 2. CHEERS (SOCIAL REACTIONS) TABLE
CREATE TABLE IF NOT EXISTS public.cheers (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  from_user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  to_user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  message TEXT DEFAULT 'Proud of you! Keep going! ❤️',
  created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL
);

ALTER TABLE public.cheers ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users can view cheers sent to or by them." ON public.cheers;
DROP POLICY IF EXISTS "Users can send cheers." ON public.cheers;

CREATE POLICY "Users can view cheers sent to or by them."
  ON public.cheers FOR SELECT
  USING (auth.uid() = to_user_id OR auth.uid() = from_user_id);

CREATE POLICY "Users can send cheers."
  ON public.cheers FOR INSERT
  WITH CHECK (auth.uid() = from_user_id);
