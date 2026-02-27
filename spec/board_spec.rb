require "../lib/board.rb"

describe Board do
  describe "#find_column" do
  subject(:board) { described_class.new }
    context "when inputs E" do
      it "returns 4" do
        result = subject.find_column('E')
        expect(result).to eq(4)
      end
    context "when inputs a" do
      it "returns 0" do
        result = subject.find_column('a')
        expect(result).to eq(0)
      end
    end
    end
  end
end