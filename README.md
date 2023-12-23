# Advent of Code 2023

Trying with Elixir...

**Log book:**
<br>

Day 1: I forgot `&Stream.replace/4` existed.

Day 2:
- Misread the first part so I fumbled it at the beggining but turned out ok.
- Part 2 was easier than part 1. Maybe biased because of the fumbling I mentioned.

Day 3:
- Learnt the existence of `&Regex.scan/3`.
- Wasn't enough pragmatic at first trying to detect a symbol by using regex lol.
- `&Regex.scan/3` is bonkers.

Day 4: Almost though I would need to use some advanced struct on the 2nd part but it turned out
as easy as the 1st part.

Day 5:
- Tried firstly with a brute force approach which was just the worst performance solution ever
(didn't expected it to be the opposite, it still was funny tho).
- So for the first part, I used my first approach and built an alternative  solution which
was way better performance wise.
- The second part was easier but took time to decide if i was going for full interval manipulations
or just turning on my computer for a whole weekday and wait.
- My favorite day yet.

Day 6: Too easy.

Day 7:
- Could have been fun If I didn't brute forced it.
- Maybe will try to redo both parts in a more efficient way even tho it didn't took more than 1.5s on average
to give the answer.

Day 8: Heavy sweat on part 2 but god bless debug print. Huge luck on this one lol.

Day 9: Too easy + lazy.

Day 10:
- Finished first part although I am not sure if it was the best way to do it but anyway.
- Didn't finished second part yet.
- First time of using a special module inside a day module. Funnily enough, it was reusable the next day.

Day 11:
- Was easy, learnt at last how to manage modules calls on the fly, because using modules which are outside
of the current file doesn't get compiled along the current executed script.
- Might not be the best performance wise but was too tired because of day 10. Didn't want to optimize. Was enough.

Day 10 bis:
- At last, completed second part, with a cool head. Wasn't that bad, I am pretty sure I just made the dumb mistake
of filtering out the points which weren't poiting to a dot char. Might be why It was wrong in the first place.

Day 12:
- Discovered Erlang Term Storage (ETS) and oh lord it is so great. For part 2 I initially just used a Map as a cache
but it was way too slow. With ETS, part_2 runned faster than part_1 (without cache). Very cool.
- Not yet fully confortable with string pattern matching, so I went the list way. And, effectively, it could have been tighter and maybe more performant to do it in this manner.

Day 13: Done it using bit operations even tho I dont think it was the best for elixir, it was funny to do.

Day 14:
- I didn't found it hard until I got bad results in part 2. I searched for more than 4 hours in total while being tired desperately trying to find where it was.
I was too focused on a "maybe the indexes are going wild" for some reason. Turned out, after some sleep and daybreak, it was just a dumb typo somewhere.
What I learnt from it: never code when tired.

Day 15: Now this was fun to do. Might be even more fun doing it in C or Rust tho.

Day 16: alcohol -> bad programming && nap -> good programming

Day 17: Messy and a bit lazy but it's working. Didn't took the time to refactor. Not a favorite.

Day 18: A bit disappointed. I wish it was more than just a change in the parsing.

Day 19: One of my favorite yet. Wished it was a bit more complex tho. My bloated code would have been more reasonnable. A bit messy at the end but working nicely.

