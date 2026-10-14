"""아이콘 SVG 원본 (24pt 격자). 고친 뒤 `python3 Tools/icons.py`로 Sources/SkimUI/Resources/Icons.xcassets를 다시 만들고,
새 아이콘이면 `Icon`에 static 멤버와 `builtIn` 항목을 더한다. 규칙은 README의 Icons 절."""
import os, json
root=os.path.join(os.path.dirname(os.path.abspath(__file__)), '../Sources/SkimUI/Resources/Icons.xcassets')
os.makedirs(root, exist_ok=True)
json.dump({"info":{"author":"xcode","version":1}}, open(f'{root}/Contents.json','w'), indent=2)
F='fill="#000"'
def fill(d, rule='nonzero', op=None):
    o=f' fill-opacity="{op}"' if op else ''
    return f'<path d="{d}" {F} fill-rule="{rule}"{o}/>'
def stroke(d, w=2.4):
    return f'<path d="{d}" fill="none" stroke="#000" stroke-width="{w}" stroke-linecap="round" stroke-linejoin="round"/>'
def rr(x,y,w,h,r):
    return f'M{x+r} {y}H{x+w-r}A{r} {r} 0 0 1 {x+w} {y+r}V{y+h-r}A{r} {r} 0 0 1 {x+w-r} {y+h}H{x+r}A{r} {r} 0 0 1 {x} {y+h-r}V{y+r}A{r} {r} 0 0 1 {x+r} {y}Z'
def circ(cx,cy,r):
    return f'M{cx-r} {cy}A{r} {r} 0 1 0 {cx+r} {cy}A{r} {r} 0 1 0 {cx-r} {cy}Z'
bell='M12 3C8.4 3 5.8 5.8 5.8 9.4V12.7L4.1 15.5C3.6 16.4 4.2 17.5 5.2 17.5H18.8C19.8 17.5 20.4 16.4 19.9 15.5L18.2 12.7V9.4C18.2 5.8 15.6 3 12 3Z'
clap='M9.3 19.2H14.7A2.7 2.7 0 0 1 9.3 19.2Z'
icons={
 'chart': [fill(rr(3.5,12,4.6,8.5,1.7)), fill(rr(9.7,3.5,4.6,17,1.7)), fill(rr(15.9,8,4.6,12.5,1.7))],
 'sliders': [fill(rr(3,6,18,2.6,1.3)), fill(circ(8.5,7.3,3.4)), fill(rr(3,15.4,18,2.6,1.3)), fill(circ(15.5,16.7,3.4))],
 'minus': [fill(rr(4,10.75,16,2.5,1.25))],
 'plus': [fill(rr(10.75,4,2.5,16,1.25)), fill(rr(4,10.75,16,2.5,1.25))],
 'chevron.right': [stroke('M9.5 5.5L16 12L9.5 18.5',2.6)],
 'chevron.left': [stroke('M14.5 5.5L8 12L14.5 18.5',2.6)],
 'search': [fill(circ(10.5,10.5,7.2)+circ(10.5,10.5,4.5),'evenodd'), stroke('M15.8 15.8L20.2 20.2',2.8)],
 'check': [stroke('M5 12.5L9.7 17L19 7.5',2.6)],
 'close': [stroke('M6.5 6.5L17.5 17.5M17.5 6.5L6.5 17.5',2.6)],
 'bell': [fill(bell), fill(clap)],
 'calendar': [fill(rr(3.5,5,17,15.5,3.2)+rr(6,10.5,12,7.5,1.4)+rr(13.3,13.3,3,3,0.9),'evenodd'), fill(rr(7.2,2.8,2.2,4.8,1.1)), fill(rr(14.6,2.8,2.2,4.8,1.1))],
 'trash': [fill(rr(4,5,16,2.6,1.3)), fill(rr(9.5,2.6,5,3,1.2)), fill('M6 9H18L17.1 19.6A2 2 0 0 1 15.1 21.5H8.9A2 2 0 0 1 6.9 19.6Z')],
 'exclamation': [fill(rr(10.6,3.5,2.8,11.5,1.4)), fill(circ(12,19,1.75))],
 'info': [fill(circ(12,12,9.2)+circ(12,7.9,1.35)+rr(10.9,10.6,2.2,6.6,1.1),'evenodd')],
 'warning': [fill('M10.3 3.9A2 2 0 0 1 13.7 3.9L21.3 17.1A2 2 0 0 1 19.6 20.1H4.4A2 2 0 0 1 2.7 17.1Z'+rr(10.9,8.6,2.2,6,1.1)+circ(12,17.1,1.25),'evenodd')],
 'widget': [fill(rr(3.5,3.5,7.5,7.5,2.3)), fill(rr(13,3.5,7.5,7.5,2.3)), fill(rr(3.5,13,7.5,7.5,2.3)), fill(circ(16.75,16.75,3.75))],
 'arrow.up.right': [stroke('M7.5 16.5L16.5 7.5M9.5 7.5H16.5V14.5',2.5)],
 'link': [stroke('M10.2 13.8L13.8 10.2',2.4), stroke('M11.2 7.2L12.6 5.8A3.6 3.6 0 0 1 17.7 10.9L16.3 12.3M7.7 11.7L6.3 13.1A3.6 3.6 0 0 0 11.4 18.2L12.8 16.8',2.4)],
 'sparkle': [fill('M12 2.5C12.6 7.6 14.4 9.4 19.5 10C14.4 10.6 12.6 12.4 12 17.5C11.4 12.4 9.6 10.6 4.5 10C9.6 9.4 11.4 7.6 12 2.5Z'), fill('M18.5 15C18.8 17.2 19.3 17.7 21.5 18C19.3 18.3 18.8 18.8 18.5 21C18.2 18.8 17.7 18.3 15.5 18C17.7 17.7 18.2 17.2 18.5 15Z')],
 # 45° 연필: 뾰족한 촉 + 몸통, 틈을 두고 둥근 지우개
 'pencil': [fill('M3.8 20.2L5.3 14.8L11.4 8.7L15.3 12.6L9.2 18.7Z'), fill('M12.5 7.6L15 5A2.8 2.8 0 0 1 19 9L16.4 11.5Z')],
}
for name, parts in icons.items():
    d=f'{root}/{name}.imageset'; os.makedirs(d, exist_ok=True)
    svg=f'<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24">'+''.join(parts)+'</svg>\n'
    open(f'{d}/{name}.svg','w').write(svg)
    json.dump({"images":[{"filename":f"{name}.svg","idiom":"universal"}],"info":{"author":"xcode","version":1},
               "properties":{"preserves-vector-representation":True,"template-rendering-intent":"template"}}, open(f'{d}/Contents.json','w'), indent=2)
print(len(icons), sorted(icons))
