Feature: Basic commands
  Background:
    Given I have the config file with:
      """
      rubys:
        - name: MRI 1.8
          command: 'gem'
      """

  シナリオ: 初期化
    前提：るりまディレクトリがない
    もし「rurema --init」を実行した
    ならば、るりまディレクトリに「bitclust doctree」ができる
    かつ、データベースが再構築される

  シナリオ: DB更新
    前提：るりまディレクトリに「doctree」がある
    もし「rurema --update」を実行した
    ならば、doctreeがアップデートされる
    かつ、データベースが再構築される

  シナリオ: 検索
    前提：るりまディレクトリにデータベースがある
    前提：るりまディレクトリに「bitclust doctree db-x.x.x」がある
    もし「rurema Array」を実行した
    ならば、Arrayのドキュメントが表示される

