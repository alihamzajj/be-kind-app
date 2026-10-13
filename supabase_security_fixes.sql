-- ==============================================================================
-- BE KIND: SECURITY FIXES FOR PROFILES, FRIENDSHIPS AND CHEERS
-- Run once in the Supabase SQL editor, after supabase_schema.sql and
-- supabase_friends_schema.sql.
-- ==============================================================================

-- Helper: are two users accepted friends (in either direction)?
CREATE OR REPLACE FUNCTION public.are_friends(a UUID, b UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.friendships f
    WHERE f.status = 'accepted'
      AND ((f.user_id = a AND f.friend_id = b)
        OR (f.user_id = b AND f.friend_id = a))
  );
$$;

-- 1. PROFILES: visible only to yourself and your accepted friends
--    (previously every profile was readable by everyone).
DROP POLICY IF EXISTS "Public profiles are viewable by everyone." ON public.profiles;
DROP POLICY IF EXISTS "Profiles are viewable by self and friends." ON public.profiles;

CREATE POLICY "Profiles are viewable by self and friends."
  ON public.profiles FOR SELECT
  USING (auth.uid() = id OR public.are_friends(auth.uid(), id));

-- 2. FRIENDSHIPS: a request starts as 'pending' and only the person who
--    received it can accept it (previously a sender could create an
--    'accepted' friendship with anyone on their own).
ALTER TABLE public.friendships ALTER COLUMN status SET DEFAULT 'pending';

ALTER TABLE public.friendships DROP CONSTRAINT IF EXISTS friendships_status_check;
ALTER TABLE public.friendships
  ADD CONSTRAINT friendships_status_check CHECK (status IN ('pending', 'accepted'));

ALTER TABLE public.friendships DROP CONSTRAINT IF EXISTS friendships_not_self;
ALTER TABLE public.friendships
  ADD CONSTRAINT friendships_not_self CHECK (user_id <> friend_id);

DROP POLICY IF EXISTS "Users can insert friendships." ON public.friendships;
DROP POLICY IF EXISTS "Users can send friend requests." ON public.friendships;
DROP POLICY IF EXISTS "Recipients can accept friend requests." ON public.friendships;

CREATE POLICY "Users can send friend requests."
  ON public.friendships FOR INSERT
  WITH CHECK (auth.uid() = user_id AND status = 'pending');

CREATE POLICY "Recipients can accept friend requests."
  ON public.friendships FOR UPDATE
  USING (auth.uid() = friend_id)
  WITH CHECK (auth.uid() = friend_id AND status = 'accepted');

-- 3. CHEERS: you can only cheer your accepted friends.
DROP POLICY IF EXISTS "Users can send cheers." ON public.cheers;
DROP POLICY IF EXISTS "Users can cheer their friends." ON public.cheers;

CREATE POLICY "Users can cheer their friends."
  ON public.cheers FOR INSERT
  WITH CHECK (
    auth.uid() = from_user_id
    AND public.are_friends(from_user_id, to_user_id)
  );
