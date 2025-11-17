import router from '@ohos.router';
import { getScript } from '../model/store';
import { DetailParams } from '../model/types';
import { WarmTheme, WarmShadow } from './uiTheme';

interface CommentEntry {
  id: string;
  user: string;
  content: string;
  likes: number;
}

@Observed
class ReviewEntry {
  id: string;
  user: string;
  content: string;
  likes: number;
  liked: boolean;
  comments: CommentEntry[];

  constructor(id: string, user: string, content: string, likes: number, liked: boolean, comments: CommentEntry[]) {
    this.id = id;
    this.user = user;
    this.content = content;
    this.likes = likes;
    this.liked = liked;
    this.comments = comments;
  }
}

@Entry
@Component
struct DetailPage {
  @State sId: string = 'demo';
  @State title: string = '';
  @State difficulty: number = 0;
  @State durationMin: number = 0;
  @State intro: string = '';
  @State tagline: string = '';
  @State tags: string[] = [];
  @State mood: string = '';
  @State highlight: string = '';
  @State rating: number = 0;
  @State ratingBreakdown: number[] = [0, 0, 0];
  @State highlightCards: string[] = [];
  @State genre: string = '';
  @State coverSeed: string = '剧';
  @State reviews: ReviewEntry[] = [
    new ReviewEntry('r1', '晨光旅人', '线索像雨滴一样串联，最后一步特别治愈。建议注意煤油灯的提示！', 24, false, [
      { id: 'r1c1', user: '悦悦呀', content: '感谢提醒！', likes: 1 }
    ]),
    new ReviewEntry('r2', '独白收集者', '节奏很温柔，中途可以多回到书房整理思路。希望有更多结局。', 18, false, []),
    new ReviewEntry('r3', '半夏', '喜欢这种记忆系剧情，背景音乐再丰富些就完美了。', 11, false, [])
  ];
  @State showAllReviews: boolean = false;
  @State editingReviewId: string = '';
  @State commentDraft: string = '';
  @State likeStates: Map<string, boolean> = new Map([['r1', false], ['r2', false], ['r3', false]]);
  @State likeCounts: Map<string, number> = new Map([['r1', 24], ['r2', 18], ['r3', 11]]);
  @State commentLikeStates: Map<string, boolean> = new Map([['r1c1', false]]);
  @State commentLikeCounts: Map<string, number> = new Map([['r1c1', 1]]);
  @State expandedComments: Set<string> = new Set();
  @State loaded: boolean = false;

  aboutToAppear() {
    try {
      const p = router.getParams() as DetailParams | undefined;
      if (p && p.id) this.sId = p.id;
    } catch (_) {}

    const s = getScript(this.sId);
    if (s) {
      this.title = s.title;
      this.difficulty = s.difficulty;
      this.durationMin = s.durationMin;
      this.intro = s.intro;
      this.tagline = s.tagline ?? '';
      this.tags = s.tags ?? [];
      this.mood = s.mood ?? '';
      this.highlight = s.highlight ?? '';
      this.rating = s.rating ?? 8.6;
      const base = this.rating;
      this.ratingBreakdown = [
        Math.min(9.9, parseFloat((base + 0.2).toFixed(1))),
        Math.min(9.8, parseFloat((base - 0.1).toFixed(1))),
        Math.min(9.5, parseFloat((base - 0.3).toFixed(1)))
      ];
      this.highlightCards = s.highlights ? s.highlights.map((h) => `${h.title} · ${h.description}`) : [];
      this.genre = s.genre ?? '悬疑';
      this.coverSeed = s.title.length > 0 ? s.title.substring(0, 1) : '剧';
      this.loaded = true;
    } else {
      this.title = '';
      this.difficulty = 0;
      this.durationMin = 0;
      this.intro = '';
      this.tagline = '';
      this.tags = [];
      this.mood = '';
      this.highlight = '';
      this.rating = 0;
      this.ratingBreakdown = [0, 0, 0];
      this.highlightCards = [];
      this.genre = '';
      this.coverSeed = '剧';
      this.loaded = false;
    }
  }

  private difficultyLabel(): string {
    if (this.difficulty <= 1) return '新手友好';
    if (this.difficulty === 2) return '进阶挑战';
    return '硬核逻辑';
  }

  private displayedReviews(): ReviewEntry[] {
    return this.showAllReviews ? this.reviews : this.reviews.slice(0, 2);
  }

  private toggleLike(reviewId: string) {
    const currentLiked = this.likeStates.get(reviewId) ?? false;
    const currentCount = this.likeCounts.get(reviewId) ?? 0;
    
    this.likeStates.set(reviewId, !currentLiked);
    this.likeCounts.set(reviewId, currentCount + (!currentLiked ? 1 : -1));
    
    // 强制触发更新
    this.likeStates = new Map(this.likeStates);
    this.likeCounts = new Map(this.likeCounts);
  }

  private startComment(reviewId: string) {
    this.editingReviewId = reviewId;
    this.commentDraft = '';
  }

  private submitComment() {
    if (!this.editingReviewId || this.commentDraft.trim().length === 0) {
      return;
    }
    const text = this.commentDraft.trim();
    const index = this.reviews.findIndex((r: ReviewEntry) => r.id === this.editingReviewId);
    if (index !== -1) {
      // 生成新的评论ID
      const newCommentId = `${this.editingReviewId}c${this.reviews[index].comments.length + 1}`;
      const newComment: CommentEntry = {
        id: newCommentId,
        user: '当前用户',
        content: text,
        likes: 0
      };
      this.reviews[index].comments.push(newComment);
      // 初始化点赞状态
      this.commentLikeStates.set(newCommentId, false);
      this.commentLikeCounts.set(newCommentId, 0);
      // 强制触发数组更新
      this.reviews = this.reviews.slice();
      this.commentLikeStates = new Map(this.commentLikeStates);
      this.commentLikeCounts = new Map(this.commentLikeCounts);
    }
    this.editingReviewId = '';
    this.commentDraft = '';
  }

  private cancelComment() {
    this.editingReviewId = '';
    this.commentDraft = '';
  }

  private toggleComments(reviewId: string) {
    if (this.expandedComments.has(reviewId)) {
      this.expandedComments.delete(reviewId);
    } else {
      this.expandedComments.add(reviewId);
    }
    // 强制触发更新
    this.expandedComments = new Set(this.expandedComments);
  }

  private toggleCommentLike(commentId: string) {
    const currentLiked = this.commentLikeStates.get(commentId) ?? false;
    const currentCount = this.commentLikeCounts.get(commentId) ?? 0;
    
    this.commentLikeStates.set(commentId, !currentLiked);
    this.commentLikeCounts.set(commentId, currentCount + (!currentLiked ? 1 : -1));
    
    // 强制触发更新
    this.commentLikeStates = new Map(this.commentLikeStates);
    this.commentLikeCounts = new Map(this.commentLikeCounts);
  }

  build() {
    Scroll() {
      Column({ space: 22 }) {
        if (!this.loaded) {
          Text('加载中…').padding(16).fontColor(WarmTheme.textPrimary)
        } else {
          Column({ space: 18 }) {
            Row({ space: 12 }) {
              Button('◀').backgroundColor('transparent').fontColor(WarmTheme.textPrimary).onClick(() => {
                try { router.back() } catch (_) {}
              })
              Text('剧本详情').fontColor(WarmTheme.textSecondary).fontSize(13)
              Blank()
              Text('…').fontSize(18).fontColor(WarmTheme.textSecondary)
            }.padding({ left: 20, right: 20, top: 12 })

            Column({ space: 16 }) {
              Row({ space: 18 }) {
                Column() {
                  Text(this.coverSeed).fontSize(34).fontWeight(FontWeight.Bold).fontColor(WarmTheme.textPrimary)
                }
                .width(110)
                .height(150)
                .backgroundColor('#FFE2CE')
                .borderRadius(24)
                .alignItems(HorizontalAlign.Center)
                .justifyContent(FlexAlign.Center)

                Column({ space: 10 }) {
                  Column({ space: 4 }) {
                    Text(this.title).fontSize(22).fontWeight(FontWeight.Bold).fontColor(WarmTheme.textPrimary)
                    if (this.tagline.length > 0) {
                      Text(this.tagline).fontSize(13).fontColor(WarmTheme.textSecondary)
                    }
                  }
                  Row({ space: 8 }) {
                    Text(this.genre).fontSize(12).fontColor(WarmTheme.textSecondary)
                    Text(this.difficultyLabel()).fontSize(12).fontColor(WarmTheme.textSecondary)
                    Text(`约 ${this.durationMin} 分钟`).fontSize(12).fontColor(WarmTheme.textSecondary)
                  }
                  Row({ space: 6 }) {
                    ForEach(this.tags.slice(0, 4), (tag: string) => {
                      Text(tag)
                        .fontSize(11)
                        .fontColor(WarmTheme.textSecondary)
                        .padding({ left: 10, right: 10, top: 4, bottom: 4 })
                        .backgroundColor('#FFF2E5')
                        .borderRadius(12)
                    })
                  }
                }.layoutWeight(1)
              }

              Row({ space: 12 }) {
                Button('想玩')
                  .backgroundColor('#FFE3CF')
                  .fontColor(WarmTheme.accentDark)
                  .borderRadius(20)
                  .onClick(() => {
                    try { router.pushUrl({ url: 'pages/PlayPage', params: { id: this.sId } }) } catch (_) {}
                  })
                Button('写测评')
                  .backgroundColor('#F9E7DB')
                  .fontColor(WarmTheme.textPrimary)
                  .borderRadius(20)
                  .onClick(() => {
                    try { router.pushUrl({ url: 'pages/ReviewPage', params: { id: this.sId, title: this.title } }) } catch (_) {}
                  })
                Blank()
              }
            }
            .padding(22)
            .backgroundColor(WarmTheme.card)
            .borderRadius(32)
            .shadow(WarmShadow.card)
          }

          Column({ space: 16 }) {
            Text('玩家评分').fontSize(16).fontWeight(FontWeight.Medium).fontColor(WarmTheme.textPrimary)
            Row({ space: 12 }) {
              Column({ space: 6 }) {
                Text(this.rating.toFixed(1)).fontSize(34).fontWeight(FontWeight.Bold).fontColor(WarmTheme.accentDark)
                Text('综合评价').fontSize(12).fontColor(WarmTheme.textSecondary)
                Text('基于 14466 位玩家统计').fontSize(10).fontColor('#B49987')
              }
              Column({ space: 12 }) {
                ForEach(['剧情', '情绪', '推理'], (label: string, index: number) => {
                  Row({ space: 10 }) {
                    Text(label).fontSize(12).fontColor(WarmTheme.textSecondary)
                    Progress({ value: this.ratingBreakdown[index], total: 10, type: ProgressType.Linear })
                      .layoutWeight(1)
                      .height(4)
                    Text(this.ratingBreakdown[index].toFixed(1)).fontSize(12).fontColor(WarmTheme.textPrimary)
                  }
                })
              }.layoutWeight(1)
            }.padding(18).backgroundColor('#FFF2E5').borderRadius(26)
          }.padding({ left: 20, right: 20 })

          Column({ space: 12 }) {
            Text('用户评价').fontSize(16).fontWeight(FontWeight.Medium).fontColor(WarmTheme.textPrimary).padding({ left: 4 })
            Column({ space: 16 }) {
              ForEach(this.displayedReviews(), (review: ReviewEntry) => {
                Column({ space: 0 }) {
                  Row({ space: 12 }) {
                    Row() {
                      Text('👤').fontSize(20)
                    }
                    .width(46)
                    .height(46)
                    .borderRadius(23)
                    .backgroundColor('#F5E6D9')
                    .justifyContent(FlexAlign.Center)
                    .alignItems(VerticalAlign.Center)

                    Column({ space: 12 }) {
                      Row({ space: 0 }) {
                        Text(review.user).fontSize(15).fontWeight(FontWeight.Medium).fontColor(WarmTheme.textPrimary)
                        Blank()
                      }
                      Text(review.content).fontSize(14).lineHeight(24).fontColor(WarmTheme.textSecondary)
                      Row({ space: 8 }) {
                        Text('昨天 22:33').fontSize(11).fontColor('#999999')
                        Text('福建').fontSize(11).fontColor('#999999')
                        Text('回复').fontSize(11).fontColor('#999999').fontWeight(FontWeight.Medium)
                          .onClick(() => { this.startComment(review.id) })
                        Blank()
                        Column({ space: 2 }) {
                          SymbolGlyph(this.likeStates.get(review.id) ? $r('sys.symbol.heart_fill') : $r('sys.symbol.heart'))
                            .fontSize(18)
                            .fontColor([this.likeStates.get(review.id) ? '#FF5A5F' : '#999999'])
                            .onClick(() => { 
                              this.toggleLike(review.id);
                            })
                          Text(`${this.likeCounts.get(review.id) ?? 0}`)
                            .fontSize(11)
                            .fontColor('#999999')
                        }
                        .onClick(() => { 
                          this.toggleLike(review.id);
                        })
                        Text('😊').fontSize(16).fontColor('#999999')
                      }
                      
                      if (review.comments.length > 0) {
                        Column({ space: 0 }) {
                          Divider().color('#EEEEEE').margin({ top: 8, bottom: 8 })
                          Text(this.expandedComments.has(review.id) ? `收起回复` : `展开 ${review.comments.length} 条回复`)
                            .fontSize(12)
                            .fontColor('#666666')
                            .onClick(() => {
                              this.toggleComments(review.id);
                            })
                        }
                      }
                      
                      if (this.expandedComments.has(review.id) && review.comments.length > 0) {
                        Column({ space: 0 }) {
                          ForEach(review.comments, (comment: CommentEntry) => {
                            Column({ space: 0 }) {
                              Row({ space: 12 }) {
                                Row() {
                                  Text('👤').fontSize(20)
                                }
                                .width(46)
                                .height(46)
                                .borderRadius(23)
                                .backgroundColor('#F5E6D9')
                                .justifyContent(FlexAlign.Center)
                                .alignItems(VerticalAlign.Center)

                                Column({ space: 12 }) {
                                  Row({ space: 0 }) {
                                    Text(comment.user).fontSize(15).fontWeight(FontWeight.Medium).fontColor(WarmTheme.textPrimary)
                                    Blank()
                                  }
                                  Text(comment.content).fontSize(14).lineHeight(24).fontColor(WarmTheme.textSecondary)
                                  Row({ space: 8 }) {
                                    Text('1小时前').fontSize(11).fontColor('#999999')
                                    Text('北京').fontSize(11).fontColor('#999999')
                                    Text('回复').fontSize(11).fontColor('#999999').fontWeight(FontWeight.Medium)
                                    Blank()
                                    Column({ space: 2 }) {
                                      SymbolGlyph((this.commentLikeStates.get(comment.id) ?? false) ? $r('sys.symbol.heart_fill') : $r('sys.symbol.heart'))
                                        .fontSize(18)
                                        .fontColor([(this.commentLikeStates.get(comment.id) ?? false) ? '#FF5A5F' : '#999999'])
                                        .onClick(() => { 
                                          this.toggleCommentLike(comment.id);
                                        })
                                      Text(`${this.commentLikeCounts.get(comment.id) ?? 0}`)
                                        .fontSize(11)
                                        .fontColor('#999999')
                                    }
                                    .onClick(() => { 
                                      this.toggleCommentLike(comment.id);
                                    })
                                    Text('😊').fontSize(16).fontColor('#999999')
                                  }
                                }.layoutWeight(1).alignItems(HorizontalAlign.Start)
                              }.alignItems(VerticalAlign.Top)
                            }
                            .padding(16)
                            .backgroundColor('#FAFAFA')
                            .borderRadius(0)
                            .margin({ bottom: 1 })
                          }, (comment: CommentEntry) => comment.id)
                        }.margin({ top: 8 })
                      }
                    }.layoutWeight(1).alignItems(HorizontalAlign.Start)
                  }.alignItems(VerticalAlign.Top)

                  if (this.editingReviewId === review.id) {
                    Column({ space: 8 }) {
                      TextInput({ placeholder: '写下你的回应…', text: this.commentDraft })
                        .onChange((value: string) => { this.commentDraft = value })
                        .height(80)
                        .backgroundColor('#F8F8F8')
                        .borderRadius(12)
                      Row({ space: 10 }) {
                        Button('发送')
                          .type(ButtonType.Capsule)
                          .backgroundColor(WarmTheme.accent)
                          .fontColor('#FFFFFF')
                          .fontSize(12)
                          .onClick(() => { this.submitComment() })
                        Button('取消')
                          .backgroundColor('#F0F0F0')
                          .fontColor('#666666')
                          .fontSize(12)
                          .borderRadius(18)
                          .onClick(() => { this.cancelComment() })
                      }
                    }.padding({ top: 12 })
                  }
                }
                .padding(16)
                .backgroundColor('#FAFAFA')
                .borderRadius(0)
                .margin({ bottom: 1 })
              }, (review: ReviewEntry) => review.id)
            }
            Row({ space: 10 }) {
              Button(this.showAllReviews ? '收起评价' : '展开更多')
                .type(ButtonType.Capsule)
                .backgroundColor('#F4E6DA')
                .fontColor(WarmTheme.textPrimary)
                .fontSize(13)
                .onClick(() => { this.showAllReviews = !this.showAllReviews })
              Blank()
            }.padding({ left: 4, right: 4 })
          }.padding({ left: 20, right: 20 })

          Column({ space: 12 }) {
            Text('剧情简介').fontSize(16).fontWeight(FontWeight.Medium).fontColor(WarmTheme.textPrimary)
            Text(this.intro).fontSize(14).lineHeight(24).fontColor(WarmTheme.textSecondary)
          }.padding({ left: 20, right: 20 })

          if (this.highlightCards.length > 0 || this.mood.length > 0 || this.highlight.length > 0) {
            Column({ space: 12 }) {
              if (this.mood.length > 0) {
                Column({ space: 6 }) {
                  Text('沉浸氛围').fontSize(15).fontWeight(FontWeight.Medium).fontColor(WarmTheme.textPrimary)
                  Text(this.mood).fontSize(13).fontColor(WarmTheme.textSecondary)
                }
              }
              if (this.highlight.length > 0) {
                Column({ space: 6 }) {
                  Text('亮点设定').fontSize(15).fontWeight(FontWeight.Medium).fontColor(WarmTheme.textPrimary)
                  Text(this.highlight).fontSize(13).fontColor(WarmTheme.textSecondary)
                }
              }
              ForEach(this.highlightCards, (desc: string) => {
                Text(desc).fontSize(13).fontColor(WarmTheme.textSecondary).padding({ top: 6, bottom: 6 })
                  .backgroundColor('#FFF6EE').borderRadius(14).padding({ left: 12, right: 12 })
              }, (desc: string) => desc)
            }.padding({ left: 20, right: 20 }).backgroundColor(WarmTheme.card).borderRadius(26).padding({ top: 16, bottom: 16 }).shadow(WarmShadow.light)
          }

          Button('立即开始推理')
            .type(ButtonType.Capsule)
            .fontSize(16)
            .backgroundColor(WarmTheme.accent)
            .fontColor('#FFFFFF')
            .margin({ left: 20, right: 20, bottom: 36, top: 4 })
            .onClick(() => {
              try { router.pushUrl({ url: 'pages/PlayPage', params: { id: this.sId } }) } catch (_) {}
            })
        }
      }.padding({ bottom: 24 })
    }.scrollBar(BarState.Off).height('100%').backgroundColor(WarmTheme.background)
  }
} 
