"""아이콘 SVG 원본 (24pt 격자). 고친 뒤 `python3 Tools/icons.py`로 Sources/SkimUI/Resources/Icons.xcassets를 다시 만들고,
새 아이콘이면 `Icon`에 static 멤버와 `builtIn` 항목을 더한다. 규칙은 README의 Icons 절."""
import os, json, math
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
def n(v):
    return f'{round(v,2):g}'
def rpoly(pts, r):
    """꼭짓점마다 모서리를 r(숫자 또는 꼭짓점별 목록)만큼 둥글린 다각형."""
    rs=r if isinstance(r, list) else [r]*len(pts)
    k=len(pts); ins=[]; outs=[]
    for i,(x,y) in enumerate(pts):
        (px,py),(qx,qy)=pts[i-1], pts[(i+1)%k]
        dp=math.hypot(px-x,py-y); dq=math.hypot(qx-x,qy-y)
        t=min(rs[i], dp/2, dq/2)
        ins.append((x+(px-x)*t/dp, y+(py-y)*t/dp)); outs.append((x+(qx-x)*t/dq, y+(qy-y)*t/dq))
    d=f'M{n(outs[-1][0])} {n(outs[-1][1])}'
    for i,(x,y) in enumerate(pts):
        d+=f'L{n(ins[i][0])} {n(ins[i][1])}Q{n(x)} {n(y)} {n(outs[i][0])} {n(outs[i][1])}'
    return d+'Z'
def polar(cx,cy,r,deg):
    a=math.radians(deg); return (cx+r*math.cos(a), cy+r*math.sin(a))
# 톱니 8개: 뿌리는 반지름 7.3, 끝은 9.5
gear=[p for i in range(8) for p in (polar(12,12,7.3,i*45-17), polar(12,12,9.5,i*45-10), polar(12,12,9.5,i*45+10), polar(12,12,7.3,i*45+17))]
# 별: 바깥 꼭짓점은 크게, 안쪽은 작게 둥글린다
star=[polar(12,12.6,9.6 if i%2==0 else 4.7,-90+i*36) for i in range(10)]
# 초승달: 큰 원에서 오른쪽 위 원을 뺀다
def moon():
    (x1,y1,r1),(x2,y2,r2)=(12,12.2,8.6),(17.2,7,6.6)
    dx,dy=x2-x1,y2-y1; d=math.hypot(dx,dy); a=(r1*r1-r2*r2+d*d)/(2*d); h=math.sqrt(r1*r1-a*a)
    mx,my=x1+a*dx/d, y1+a*dy/d
    p=(mx+h*dy/d, my-h*dx/d); q=(mx-h*dy/d, my+h*dx/d)
    return f'M{n(p[0])} {n(p[1])}A{r1} {r1} 0 1 0 {n(q[0])} {n(q[1])}A{r2} {r2} 0 0 1 {n(p[0])} {n(p[1])}Z'
folder='M3 7.2A2.7 2.7 0 0 1 5.7 4.5H9.1C9.8 4.5 10.4 4.8 10.9 5.3L12.1 6.5H18.3A2.7 2.7 0 0 1 21 9.2V16.8A2.7 2.7 0 0 1 18.3 19.5H5.7A2.7 2.7 0 0 1 3 16.8Z'
bell='M12 3C8.4 3 5.8 5.8 5.8 9.4V12.7L4.1 15.5C3.6 16.4 4.2 17.5 5.2 17.5H18.8C19.8 17.5 20.4 16.4 19.9 15.5L18.2 12.7V9.4C18.2 5.8 15.6 3 12 3Z'
clap='M9.3 19.2H14.7A2.7 2.7 0 0 1 9.3 19.2Z'
icons={
 'chart': [fill(rr(3.5,12,4.6,8.5,1.7)), fill(rr(9.7,3.5,4.6,17,1.7)), fill(rr(15.9,8,4.6,12.5,1.7))],
 'sliders': [fill(rr(3,6,18,2.6,1.3)), fill(circ(8.5,7.3,3.4)), fill(rr(3,15.4,18,2.6,1.3)), fill(circ(15.5,16.7,3.4))],
 'minus': [fill(rr(4,10.75,16,2.5,1.25))],
 'plus': [fill(rr(10.75,4,2.5,16,1.25)), fill(rr(4,10.75,16,2.5,1.25))],
 'chevron.right': [stroke('M9.5 5.5L16 12L9.5 18.5',2.6)],
 'chevron.down': [stroke('M5.5 9.5L12 16L18.5 9.5',2.6)],
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
 'arrow.right': [stroke('M4.5 12H19M13.5 6.5L19 12L13.5 17.5',2.5)],
 # 아래 화살표 + 받침 막대 (가져오기에도 쓴다)
 'download': [stroke('M12 3.5V14M7.5 9.5L12 14L16.5 9.5',2.5), fill(rr(4,18,16,2.6,1.3))],
 # 위로 나가는 화살표 + 위가 트인 상자
 'share': [stroke('M12 3.5V13.5M8 7.5L12 3.5L16 7.5',2.4), stroke('M8.5 10H7.5A2.3 2.3 0 0 0 5.2 12.3V18.2A2.3 2.3 0 0 0 7.5 20.5H16.5A2.3 2.3 0 0 0 18.8 18.2V12.3A2.3 2.3 0 0 0 16.5 10H15.5',2.4)],
 # 앞 장은 채우고 뒷 장은 테두리만
 'copy': [fill(rr(8.5,8.5,12,12,2.6)), stroke('M15.5 5.3V5.2A1.7 1.7 0 0 0 13.8 3.5H5.2A1.7 1.7 0 0 0 3.5 5.2V13.8A1.7 1.7 0 0 0 5.2 15.5H5.3',2.2)],
 'refresh': [stroke('M19.2 12A7.2 7.2 0 1 1 16.9 6.7',2.4), stroke('M17.8 2.9V7.2H13.5',2.4)],
 'swap': [stroke('M7.5 4L4 7.5L7.5 11M4 7.5H17.5M16.5 13L20 16.5L16.5 20M20 16.5H6.5',2.4)],
 'sort': [stroke('M8 19.5V4.5M4.5 8L8 4.5L11.5 8M16 4.5V19.5M12.5 16L16 19.5L19.5 16',2.4)],
 'more': [fill(circ(5.2,12,2.1)), fill(circ(12,12,2.1)), fill(circ(18.8,12,2.1))],
 'folder': [fill(folder)],
 'folder.plus': [fill(folder+rpoly([(10.9,9.6),(13.1,9.6),(13.1,11.9),(15.4,11.9),(15.4,14.1),(13.1,14.1),(13.1,16.4),(10.9,16.4),(10.9,14.1),(8.6,14.1),(8.6,11.9),(10.9,11.9)],[0.9,0.9,0.3,0.9,0.9,0.3,0.9,0.9,0.3,0.9,0.9,0.3]),'evenodd')],
 'app': [fill(rr(3.5,3.5,17,17,5.2))],
 # widget과 달리 네 칸 모두 둥근 사각형
 'apps': [fill(rr(3.5,3.5,7.5,7.5,2.3)), fill(rr(13,3.5,7.5,7.5,2.3)), fill(rr(3.5,13,7.5,7.5,2.3)), fill(rr(13,13,7.5,7.5,2.3))],
 'gear': [fill(rpoly(gear,0.9)+circ(12,12,3.1),'evenodd')],
 'lock': [fill(rr(4.5,10,15,11,2.6)+circ(12,15.5,1.6),'evenodd'), stroke('M8 10V7.5A4 4 0 0 1 16 7.5V10',2.4)],
 'star': [fill(rpoly(star,[1.8 if i%2==0 else 0.7 for i in range(10)]))],
 # 산과 해를 뚫은 사진 틀
 'photo': [fill(rr(3,4.5,18,15,3.2)+rpoly([(5.8,16.9),(10,11.6),(13,15.1),(15,13.1),(18.2,16.9)],[0.5,1.2,0.6,1,0.5])+circ(15.4,8.8,1.9),'evenodd')],
 'globe': [stroke(circ(12,12,8.7)+'M12 3.3C9.5 5.8 8.4 8.8 8.4 12S9.5 18.2 12 20.7M12 3.3C14.5 5.8 15.6 8.8 15.6 12S14.5 18.2 12 20.7M3.8 12H20.2',2.2)],
 'moon': [fill(moon())],
 # 봉투 덮개(V)를 뚫는다
 'envelope': [fill(rr(3,5,18,14,3)+rpoly([(6.3,7.9),(12,11.9),(17.7,7.9),(18.9,9.6),(12,14.4),(5.1,9.6)],[0.9,0.4,0.9,0.9,0.6,0.9]),'evenodd')],
 # 오른쪽 위 귀를 떼어 접힌 조각으로 두고, 글줄 두 개를 뚫는다
 'doc': [fill(rpoly([(4.5,3),(11.4,3),(11.4,10.6),(19.5,10.6),(19.5,21),(4.5,21)],[2.6,1,1,1,2.6,2.6])+rr(7.8,13.4,8.4,2,1)+rr(7.8,16.8,5.4,2,1),'evenodd'), fill(rpoly([(13.2,3.4),(19.1,8.8),(13.2,8.8)],[0.8,0.8,0.8]))],
 # 손바닥: 손가락 넷 + 바닥 + 엄지
 'hand': [stroke('M9.2 12V7M12.2 11V4.6M15.2 11.5V5.6M18.2 13V8.6',2.6), fill(rpoly([(7.9,11),(19.5,11),(19.5,15.2),(15.6,21),(10,21),(7.9,17.5)],[0.8,1.2,2.4,2,3,2])), stroke('M8.6 17.2L5.6 13.6',2.6)],
 # info처럼 원에 물음표를 뚫는다: 고리 + 기둥, 점
 'question': [fill(circ(12,12,9.2)+'M8.3 9A3.7 3.7 0 1 1 13.2 12.5V13.3A1.2 1.2 0 0 1 10.8 13.3V11.6Q10.8 10.3 12 10.3A1.3 1.3 0 1 0 10.7 9A1.2 1.2 0 0 1 8.3 9Z'+circ(12,16.9,1.35),'evenodd')],
 'clock': [fill(circ(12,12,9.2)+'M10.9 7.6A1.1 1.1 0 0 1 13.1 7.6V10.9H15.4A1.1 1.1 0 0 1 15.4 13.1H12.2A1.3 1.3 0 0 1 10.9 11.8Z','evenodd')],
 'bolt': [fill(rpoly([(14,2.5),(4.8,13.8),(11.3,13.8),(10,21.5),(19.2,10.2),(12.7,10.2)],[1.2,1.2,0.6,1.2,1.2,0.6]))],
 'crown': [fill(rpoly([(3.5,7.5),(8.2,11.6),(12,4.8),(15.8,11.6),(20.5,7.5),(18.6,17),(5.4,17)],[1.1,0.8,1.3,0.8,1.1,1.2,1.2])), fill(rr(5.4,18.6,13.2,2.4,1.2))],
 # 무한대: 두 고리를 한 획으로
 'infinity': [stroke('M12 12C10.2 9.3 8.9 8 7 8A4 4 0 0 0 7 16C8.9 16 10.2 14.7 12 12C13.8 9.3 15.1 8 17 8A4 4 0 0 1 17 16C15.1 16 13.8 14.7 12 12Z',2.4)],
 'play': [fill('M8 5.6V18.4A1.3 1.3 0 0 0 10 19.5L19.6 13.1A1.3 1.3 0 0 0 19.6 10.9L10 4.5A1.3 1.3 0 0 0 8 5.6Z')],
 'stop': [fill(rr(5.5,5.5,13,13,2.8))],
 # 문을 아래에서 파낸 집
 'house': [fill(rpoly([(3.5,10.6),(12,3.4),(20.5,10.6),(19.6,10.6),(19.6,20.5),(14.2,20.5),(14.2,15),(9.8,15),(9.8,20.5),(4.4,20.5),(4.4,10.6)],[0.9,1.4,0.9,0.1,2.2,0.6,1.1,1.1,0.6,2.2,0.1]))],
 'checklist': [stroke('M3.8 7.6L5.9 9.6L9.4 5.6M3.8 16.4L5.9 18.4L9.4 14.4',2.4), fill(rr(12,6.4,8.5,2.4,1.2)), fill(rr(12,15.2,8.5,2.4,1.2))],
 # 손가락 끝 위로 터치 물결
 'tap': [stroke('M6.6 9.4A4.4 4.4 0 0 1 15.4 9.4',2.2), stroke('M11 9.6V16',2.8), fill(rpoly([(9.7,12.6),(17,12.6),(18.8,14.8),(18,19.4),(16.2,21.2),(11.8,21.2),(9.7,19)],[0.6,1.6,1.4,1.6,1.6,2,0.6])), stroke('M9.8 17.8L7.4 15.4',2.6)],
 'eye': [fill('M2.5 12C4.9 7.6 8.2 5.4 12 5.4S19.1 7.6 21.5 12C19.1 16.4 15.8 18.6 12 18.6S4.9 16.4 2.5 12Z'+circ(12,12,3.6),'evenodd'), fill(circ(12,12,1.8))],
}
for name, parts in icons.items():
    d=f'{root}/{name}.imageset'; os.makedirs(d, exist_ok=True)
    svg=f'<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24">'+''.join(parts)+'</svg>\n'
    open(f'{d}/{name}.svg','w').write(svg)
    json.dump({"images":[{"filename":f"{name}.svg","idiom":"universal"}],"info":{"author":"xcode","version":1},
               "properties":{"preserves-vector-representation":True,"template-rendering-intent":"template"}}, open(f'{d}/Contents.json','w'), indent=2)
print(len(icons), sorted(icons))
